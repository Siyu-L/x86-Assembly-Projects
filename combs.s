# Siyu Li

/* C implementation
int arr_len(int* arr) {
  if(arr == NULL) {
    return 0;
  }
  int count = 0;
  while(arr[count] != '\0') {
    count++;
  }
  return count;

}

int arr2D_len(int** arr2D) {
  if(arr2D == NULL) {
    return 0;
  }
  int count = 0;
  while(arr2D[count] != NULL) {
    count++;
  }
  return count;

}

int* append(int* arr, int num) {
  int old_len;
  if(arr != NULL) {
    old_len = arr_len(arr);
  } 
  else {
    old_len = 0;
  }
  int new_len = old_len + 1;
  int* new_arr = (int*)malloc((old_len + 2) * sizeof(int));
  for(int i = 0; i< new_len; i++) {
      if(i < old_len) {
        new_arr[i] = arr[i];
      }
      else {
        new_arr[i] = num;
      }

  }
  new_arr[new_len] = 0; //set sentinel value
  return new_arr;

}

int** concat2DArray(int** arrA, int** arrB) {

  int arrA_len = arr2D_len(arrA);
  int arrB_len = arr2D_len(arrB);
  int new_len = arrA_len + arrB_len;


  int** new_arr = (int**)malloc((new_len + 1)*sizeof(int*));
  for(int i = 0; i<new_len; i++) {
    if(i < arrA_len) {
      new_arr[i] = arrA[i];
    }
    else {
      new_arr[i] = arrB[i-arrA_len];
    }
  }

  new_arr[new_len] = NULL; // set sentinel value


  return new_arr;

}


int** create_comb(int* items, int* prev_arr, int k, int len) {
  // base case
  int prev_len = arr_len(prev_arr);
  if(prev_len == k) {
    // all_combs is just prev_arr with an extra row as sentinel value
    int** all_combs = (int**)malloc(2*sizeof(int*)); // 1 + 1 for sentinel value
    all_combs[0] = prev_arr;
    all_combs[1] = NULL; //set sentinel value
    return all_combs;
  }
  // recursive call
  // initialize all_combs
  int** all_combs = (int**)malloc(1*sizeof(int*));
  all_combs[0] = NULL;
  for(int i = 0; i < len; i++)  { // for each item in list
    int* cur_arr = append(prev_arr, items[i]); //add current item to the previous array
    all_combs = concat2DArray(all_combs, create_comb(items + i + 1, cur_arr, k, len - i - 1)); // add (all combinations of remaining items) to all combinations
  }

  return all_combs;


}

int** get_combs(int* items, int k, int len) {
  int num = num_combs(len, k);
  int** all_combs = (int**)malloc(num * sizeof(int*));
    
  // for(int i = 0; i < num; i++) {
  //   int begin[0];
  //   all_combs[i] = create_comb(items, begin, k, len);
  // }
  int* begin = NULL;
  all_combs = create_comb(items, begin, k, len);
  return all_combs;
}
*/


.global arr_len
.global arr2D_len
.global append
.global concat2DArray
.global create_comb
.global get_combs

.equ ws, 4

.text

arr_len: # int arr_len(int* arr), int arr2D_len(int** arr2D)
    # NOTE: should work even if arr is 2D
    # locals: count
    # only uses eax and ecx
    arr_len_prologue:
        push %ebp
        movl %esp, %ebp
        subl $1*ws, %esp

        /* the stack
        ebp + 2: arr
        ebp + 1: ret address
        ebp: old ebp
        ebp - 1: count
        */
        .equ arr, (2*ws) #(%ebp)
        .equ count, (-1*ws) #(%ebp)
    arr_len_prologue_end:
    # ecx will be arr, eax will be count
    movl arr(%ebp), %ecx # ecx = arr

    // if(arr == NULL)
    // negation: arr != \0
    cmpl $0, %ecx
    jnz arr_len_if_end
    arr_len_if:
        # return 0
        movl $0, %eax # eax = 0
        jmp arr_len_epilogue
    arr_len_if_end:

    # int count = 0
    movl $0, %eax # eax = 0
    # while(arr[count] != '\0')
    # negation: arr[count] == 0
    arr_len_while:
        # arr[count] = *(arr + count)
        # *(arr + count) != 0
        # negation: *(arr + count) == 0
        cmpl $0, (%ecx, %eax, ws)
        jz arr_len_while_end
        # count ++
        incl %eax
        jmp arr_len_while
    arr_len_while_end:


    arr_len_epilogue:
        # return count, which is in eax

        movl %ebp, %esp # clear locals
        pop %ebp
        ret

append: # int* append(int* arr, int num)
    # locals: old_len, new_len, new_arr, i
    .equ num_locals, 4
    .equ used_ebx, 1
    .equ used_esi, 0
    .equ used_edi, 0
    
    append_prologue:
        push %ebp
        movl %esp, %ebp
        # make room for locals and saved regs
        subl $5*ws, %esp
        /* the stack
        ebp + 3: num
        ebp + 2: arr
        ebp + 1: ret address
        ebp: old ebp
        ebp - 1: old_len
        ebp - 2: new_len
        ebp - 3: new_arr
        ebp - 4: i
        ebp - 5: old ebx
        */
        
        .equ arr, (2*ws) # (%ebp)
        .equ num, (3*ws) # (%ebp)
        .equ old_len, (-1*ws) # (%ebp)
        .equ new_len, (-2*ws) # (%ebp)
        .equ new_arr, (-3*ws) # (%ebp)
        .equ i, (-4*ws) # (%ebp)
        .equ old_ebx, (-5*ws) # (%ebp)

        # save callee saved registers
        movl %ebx, old_ebx(%ebp)

    append_prologue_end:
    
    # edx will be arr
    //if(arr != NULL) 
    # negation: arr == NULL == 0
    movl arr(%ebp), %edx
    cmpl $0, %edx
    jz append_else
    append_if:
        #old_len = arr_len(arr);
        push %edx # push arr
        call arr_len
        addl $1 * ws, %esp # clear arguments
        movl %eax, old_len(%ebp)
        jmp append_else_end
    
    append_else:
        # old_len = 0;
        movl $0, old_len(%ebp)
    
    append_else_end:

    # ecx will be new_len
    # int new_len = old_len + 1;
    movl old_len(%ebp), %ecx # ecx = old_len
    incl %ecx # ecx = old_len + 1

    # save new_len value
    movl %ecx, new_len(%ebp)

    incl %ecx # ecx = old_len + 2
    # eax will be new_arr
    # int* new_arr = (int*)malloc((old_len + 2) * sizeof(int));
    shll $2, %ecx # ecx = (old_len + 2)* sizeof(int)
    push %ecx
    movl %edx, arr(%ebp) # save arr's current value
    call malloc
    addl $1*ws, %esp # clear malloc args from stack
    movl %eax, new_arr(%ebp) # new_arr = (int*)malloc((old_len + 2) * sizeof(int));
    movl arr(%ebp), %edx # restore edx back to arr
    
    # ecx will now be i
    # for(int i = 0; i< new_len; i++)
    movl $0, %ecx # i = 0
    append_for:
        # i < new_len == i - new_len < 0
        # negation: i - new_len >= 0
        cmpl new_len(%ebp), %ecx # i - new_len
        jge append_for_end

        // if(i < old_len)
        # i < old_len == i - old_len < 0
        # negation: i - old_len >= 0
        cmpl old_len(%ebp), %ecx # i - old_len
        jge append_for_else
        append_for_if:
            # ebx will be arr
            # eax will be new_arr[i]
            # new_arr[i] = arr[i];
            movl arr(%ebp), %ebx # ebx = arr
            movl (%ebx, %ecx, ws), %ebx # ebx = *(arr + i)
            movl new_arr(%ebp), %eax # eax = new_arr
            movl %ebx, (%eax, %ecx, ws) # new_arr[i] = ebx = arr[i]
            jmp append_for_else_end

        append_for_else:
            # ebx will be num
            # new_arr[i] = num
            movl new_arr(%ebp), %eax # eax = new_arr
            movl num(%ebp), %ebx
            movl %ebx, (%eax, %ecx, ws) # new_arr[i] = ebx = num

        append_for_else_end:

        incl %ecx # i++
        jmp append_for
    append_for_end:

    # new_arr[new_len] = 0; // set sentinel value
    movl new_len(%ebp), %ebx # ebx = new_len
    movl new_arr(%ebp), %eax # eax = new_arr
    movl $0, (%eax, %ebx, ws) # *(new_arr + new_len) = 0

    append_epilogue:
        # return value new_arr already in eax

        # restore saved regs
        movl old_ebx(%ebp), %ebx

        movl %ebp, %esp
        pop %ebp
        ret


concat2DArray: # int** concat2DArray(int** arrA, int** arrB)
  # locals: arrA_len, arrB_len, new_len, new_arr, i
  .equ num_locals, 5
  .equ used_ebx, 1
  .equ used_esi, 0
  .equ used_edi, 0
  
  concat_prologue:
    push %ebp
    movl %esp, %ebp
    #make room for locals and saved regs
    subl $6*ws, %esp

    /* the stack
    ebp + 3: arrB
    ebp + 2: arrA
    ebp + 1: ret address
    ebp: old ebp
    ebp - 1: arrA_len
    ebp - 2: arrB_len
    ebp - 3: new_len
    ebp - 4: new_arr
    ebp - 5: i
    ebp - 6: old_ebx
    */

    .equ arrA, (2*ws) # (%ebp)
    .equ arrB, (3*ws) # (%ebp)
    
    .equ arrA_len, (-1*ws) # (%ebp)
    .equ arrB_len, (-2*ws) # (%ebp)
    .equ new_len, (-3*ws) # (%ebp)
    .equ new_arr, (-4*ws) # (%ebp)
    .equ i, (-5*ws) # (%ebp)
    .equ old_ebx, (-6*ws) # (%ebp)

    # save callee saved regs
    movl %ebx, old_ebx(%ebp)

  concat_prologue_end:

  # int arrA_len = arr2D_len(arrA);
  # int arrB_len = arr2D_len(arrB);

  # eax will be arrA temporarily
  # ebx will be arrB temporarily
  movl arrA(%ebp), %eax # eax = arrA
  push %eax # place arr_len args on stack
  call arr_len 
  addl $1*ws, %esp # clear args from stack
  movl %eax, arrA_len(%ebp)

  movl arrB(%ebp), %ebx # ebx = arrB
  push %ebx # place arr_len args on stack
  call arr_len
  addl $1*ws, %esp # clear args from stack
  movl %eax, arrB_len(%ebp)

  # ecx will be new_len
  movl arrA_len(%ebp), %ecx # ecx = addA_len
  addl arrB_len(%ebp), %ecx # ecx = addA_len + addB_len
  movl %ecx, new_len(%ebp) # save new_len value

  # int** new_arr = (int**)malloc((new_len + 1)*sizeof(int*));
  incl %ecx # ecx = new_len + 1
  shll $2, %ecx # ecx = (new_len + 1) * sizeof(int*)
  push %ecx # place malloc args on stack
  call malloc # return value in %eax
  addl $1*ws, %esp # clear args from stack
  movl %eax, new_arr(%ebp) # new_arr = (int**)malloc((new_len + 1)*sizeof(int*));

  # for(int i = 0; i<new_len; i++)
  # ecx will be i
  movl $0, %ecx # i = 0
  concat_for:
    # i < new_len == i - new_len < 0
    # negation: i - new_len >= 0
    cmpl new_len(%ebp), %ecx # i - new_len
    jge concat_for_end

    // if(i < arrA_len) 
    # i < arrA_len == i - arrA_len <  0
    # negation: i - arrA_len >= 0
    cmpl arrA_len(%ebp), %ecx # i - arrA_len
    jge concat_else
    concat_if:
      # new_arr[i] = arrA[i];
      # edx will be arrA, ebx will be new_arr
      movl arrA(%ebp), %edx # edx = arrA
      movl (%edx, %ecx, ws), %edx # edx = arrA[i]
      movl new_arr(%ebp), %ebx # ebx = new_arr
      movl %edx, (%ebx, %ecx, ws) # new_arr[i] = edx = arrA[i]

      jmp concat_else_end
    concat_else:
      # new_arr[i] = arrB[i-arrA_len];
      # arrB[i-arrA_len] = *(arrB + (i - arrA_len))
      # eax will  be i-arrA_len, edx will be arrB, ebx will be new_arr
      movl %ecx, %eax # eax = i
      subl arrA_len(%ebp), %eax # eax = i - arrA_len
      movl arrB(%ebp), %edx # edx = arrB
      movl (%edx, %eax, ws), %edx # edx  = arrB[i-arrA_len]
      movl new_arr(%ebp), %ebx # ebx = new_arr
      movl %edx, (%ebx, %ecx, ws) # new_arr[i] = edx = arrB[i-arrA_len]
    concat_else_end:

    incl %ecx # i++
    jmp concat_for
  concat_for_end:

  #   new_arr[new_len] = NULL; // set sentinel value
  # ecx no longer used, so use it as new_len
  # eax will be new_arr
  movl new_len(%ebp), %ecx # ecx = new_len
  movl new_arr(%ebp), %eax # eax = new_arr
  movl $0, (%eax, %ecx, ws) # new_arr[new_len] = 0

  concat_epilogue:
    # return value is new_arr, already in eax
    # restore saved regs
    movl old_ebx(%ebp), %ebx

    movl %ebp, %esp
    pop %ebp
    ret

create_comb: # int** create_comb(int* items, int* prev_arr, int k, int len)
  # locals: prev_len, all_combs, i, cur_arr
  .equ num_locals, 4
  .equ used_ebx, 1
  .equ used_esi, 0
  .equ used_edi, 0
  create_prologue:
    push %ebp
    movl %esp, %ebp
    # make space for locals and saved regs
    subl $5*ws, %esp
    
    /* the stack
    ebp + 5: len
    ebp + 4: k
    ebp + 3: prev_arr
    ebp + 2: items
    ebp + 1: ret address
    ebp: old ebp
    ebp - 1: prev_len
    ebp - 2: all_combs
    ebp - 3: i
    ebp - 4: cur_arr
    ebp - 5: old_ebx
    */
    .equ items, (2*ws) # (%ebp)
    .equ prev_arr, (3*ws) # (%ebp)
    .equ k, (4*ws) # (%ebp)
    .equ len, (5*ws) # (%ebp)

    .equ prev_len, (-1*ws) # (%ebp)
    .equ all_combs, (-2*ws) # (%ebp)
    .equ i, (-3*ws) # (%ebp)
    .equ cur_arr, (-4*ws) # (%ebp)
    .equ old_ebx, (-5*ws) # (%ebp)

    # save callee saved reg
    movl %ebx, old_ebx(%ebp) 
  create_prologue_end:
  
  # int prev_len = arr_len(prev_arr);
  # edx will be prev_arr
  movl prev_arr(%ebp), %edx
  push %edx # place arr_len args on stack
  call arr_len # result in eax
  addl $1*ws, %esp # clear args from stack
  movl %eax, prev_len(%ebp) # prev_len = arr_len(prev_arr)

  // if(prev_len == k)
  # prev_len == k == prev_len - k == 0
  # negation: prev_len - k != 0
  # prev_len currently in eax
  cmpl k(%ebp), %eax # prev_len - k
  jnz create_if_end
  create_if:
    # int** all_combs = (int**)malloc(2*sizeof(int*)); // 1 + 1 for sentinel value
    # ecx will be used for malloc args
    movl $2, %ecx # ecx = 2
    shll $2, %ecx # ecx = 2 * sizeof(int*)
    push %ecx # place malloc args on stack
    call malloc # result in eax
    addl $1*ws, %esp # clear malloc args from stack
    movl %eax, all_combs(%ebp) # all_combs = (int**)malloc(2*sizeof(int*));
    # all_combs[0] = prev_arr;
    # eax currently holds all_combs
    movl prev_arr(%ebp), %edx # edx = prev_arr
    movl %edx, (%eax) # *(eax) = *(arr_combs) = arr_combs[0] = prev_arr
    # all_combs[1] = NULL; //set sentinel value
    # all_combs[1] = *(all_combs + 1)
    movl $0, 1*ws(%eax)
    # return all_combs;
    jmp create_epilogue
  create_if_end:
  
  # int** all_combs = (int**)malloc(1*sizeof(int*));
  # ecx will be used for malloc args
  movl $1, %ecx # ecx = 1
  shll $2, %ecx # ecx = 1 * sizeof(int*)
  push %ecx # place malloc args on stack
  call malloc # return value in eax
  addl $1*ws, %esp # clear malloc args from stack
  movl %eax, all_combs(%ebp) # all_combs = (int**)malloc(1*sizeof(int*));

  # all_combs[0] = NULL;
  # eax currently holds all_combs
  movl $0, (%eax) # arr_combs[0] = 0
 
  # for(int i = 0; i < len; i++)  { // for each item in list
  # ecx will be i
  movl $0, %ecx # ecx = 0
  create_for:
    # i < len == i - len < 0
    # negation: i - len >= 0
    cmpl len(%ebp), %ecx # i - len
    jge create_for_end

    # int* cur_arr = append(prev_arr, items[i]); //add current item to the previous array
    # ebx will be used to push args for append
    
    # items[i]
    movl items(%ebp), %ebx # ebx = items
    movl (%ebx, %ecx, ws), %ebx # ebx = items[i]
    push %ebx

    # prev_arr
    movl prev_arr(%ebp), %ebx # ebx = prev_arr
    push %ebx

    # save i's current value
    movl %ecx, i(%ebp)
    call append # result in eax
    addl $2*ws, %esp # clear append args
    movl %eax, cur_arr(%ebp)

    # restore ecx back to i
    movl i(%ebp), %ecx

    # all_combs = concat2DArray(all_combs, create_comb(items + i + 1, cur_arr, k, len - i - 1));
    # create_comb(items + i + 1, cur_arr, k, len - i - 1)
    # ebx will be used to push args for create_comb
    
    # len - i - 1
    movl len(%ebp), %ebx
    subl %ecx, %ebx # ebx = len - i
    decl %ebx # ebx = len - i - 1
    push %ebx

    # k
    movl k(%ebp), %ebx # ebx = k
    push %ebx

    # cur_arr
    movl cur_arr(%ebp), %ebx # ebx = cur_arr
    push %ebx

    # items + i + 1
    # NOTE: items is an array
    movl items(%ebp), %ebx
    leal ws(%ebx, %ecx, ws), %ebx # ebx = items + i + 1
    push %ebx
    call create_comb # result in eax
    addl $4*ws, %esp # clear create_comb args
    
    # concat2DArray(all_combs, create_comb(...))
    # currently eax stores create_comb(...)

    # create_comb(...)
    push %eax

    # all_combs
    movl all_combs(%ebp), %ebx # ebx = all_combs
    push %ebx
    call concat2DArray # result in eax
    addl $2*ws, %esp # clear concat2DArray args
    movl %eax, all_combs(%ebp)
    
    # restore i's value
    movl i(%ebp), %ecx # ecx = i
    incl %ecx # i++
    jmp create_for
  create_for_end:

  create_epilogue:
    # set return value
    movl all_combs(%ebp), %eax

    # restore callee saved regs
    movl old_ebx(%ebp), %ebx
    movl %ebp, %esp # clear locals and saved reg space
    pop %ebp
    ret


get_combs: # int** get_combs(int* items, int k, int len)
  # locals: num, all_combs, begin
  # no callee saved regs used
  .equ num_locals, 3
  get_combs_prologue:
    push %ebp
    movl %esp, %ebp
    # make space for locals
    subl $3*ws, %esp

    /* the stack
    ebp + 4: len
    ebp + 3: k
    ebp + 2: items
    ebp + 1: return address
    ebp: old ebp
    ebp - 1: num
    ebp - 2: all_combs
    ebp - 3: begin
    */
    
    .equ items, (2*ws) # (%ebp)
    .equ k, (3*ws) # (%ebp)
    .equ len, (4*ws) # (%ebp)

    .equ num, (-1*ws) # (%ebp)
    .equ all_combs, (-2*ws) # (%ebp)
    .equ begin, (-3*ws) # (%ebp)

  get_combs_prologue_end:
  
  # int num = num_combs(len, k);
  # edx will be used to push num_combs args
  
  # k
  movl k(%ebp), %edx # edx = k
  push %edx

  # len
  movl len(%ebp), %edx # edx = len
  push %edx
  call num_combs # result in eax
  addl $2*ws, %esp # clear num_combs args from stack
  movl %eax, num(%ebp) # num = num_combs(len, k);

  # int** all_combs = (int**)malloc(num * sizeof(int*));
  # eax currently stores num
  shll $2, %eax # eax = num * sizeof(int*)
  push %eax
  call malloc # return value in eax
  addl $1*ws, %esp # clear malloc args from stack
  movl %eax, all_combs(%ebp) # all_combs = (int**)malloc(num * sizeof(int*));

  # int* begin = NULL;
  movl $0, begin(%ebp)

  # all_combs = create_comb(items, begin, k, len);
  # edx will be used to push create_comb args
  
  # len
  movl len(%ebp), %edx
  push %edx

  # k
  movl k(%ebp), %edx
  push %edx

  # begin
  movl begin(%ebp), %edx
  push %edx

  # items
  movl items(%ebp), %edx
  push %edx
  call create_comb
  addl $4*ws, %esp # clear create_comb args
  movl %eax, all_combs(%ebp)

  get_combs_epilogue:
    # return value already in eax
    # no callee saved regs used
    movl %ebp, %esp # clear locals
    pop %ebp
    ret

