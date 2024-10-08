mergeSort2:
    stp x3,lr,[sp,-16]!    // save  registers
    stp x4,x5,[sp,-16]!    // save  registers
    stp x6,x7,[sp,-16]!    // save  registers

    cmp w2,2               // end ?
    blt merge_sort_end2

    // Imprimir el arreglo antes de la división
    ADD x11, x11 , 1       // Incrementar el contador para imprimir
    bl print_array         // Llamar a la rutina para imprimir el arreglo

    lsr x4,x2,1            // number of element of each subset
    add x5,x4,1
    tst x2,#1              // odd ?
    csel x4,x5,x4,ne
    mov x5,x1              // save first element
    mov x6,x2              // save number of elements
    mov x7,x4              // save number of elements of each subset
    mov x2,x4
    bl mergeSort2

    mov x1,x7              // restaur number of elements of each subset
    mov x2,x6              // restaur number of elements
    sub x2,x2,x1
    mov x3,x5              // restaur first element
    add x1,x1,x3           // + 1
    bl mergeSort2           // sort first subset

    // Imprimir el arreglo después de ordenar la primera parte
    ADD x11, x11 , 1       // Incrementar el contador para imprimir
    bl print_array         // Llamar a la rutina para imprimir el arreglo

    mov x1,x5              // restaur first element
    mov x2,x7              // restaur number of elements of each subset
    add x2,x2,x1
    mov x3,x6              // restaur number of elements
    add x3,x3,x1 
    sub x3,x3,1            // last index
    bl merge2              // fusionar ambas partes

merge_sort_end2:
    ldp x6,x7,[sp],16      // restaur 2 registers
    ldp x4,x5,[sp],16      // restaur 2 registers
    ldp x3,lr,[sp],16      // restaur 2 registers
    ret                     // return to address lr x30

/************** merge ****************/
merge2:
    stp x1,lr,[sp,-16]!    // save registers
    stp x2,x3,[sp,-16]!    // save registers
    stp x4,x5,[sp,-16]!    // save registers
    stp x6,x7,[sp,-16]!    // save registers
    str x8,[sp,-16]!
    mov x5,x2              // init index x2->x5 

    // Imprimir el arreglo antes de fusionar
    ADD x11, x11 , 1       // Incrementar el contador para imprimir
    bl print_array         // Llamar a la rutina para imprimir el arreglo

    first_section_loop2:            // begin loop first section
        ldr w6,[x0,x1,lsl 2]       // load value first section index r1
        ldr w7,[x0,x5,lsl 2]       // load value second section index r5
        cmp w6,w7
        ble second_section_advance2 // <=  -> location first section OK
        str w7,[x0,x1,lsl 2]       // store value second section in first section
        add x8,x5,1
        cmp w8,w3                  // end second section ?
        ble insert_element2
        str w6,[x0,x5,lsl 2]
        b second_section_advance2   // loop

    insert_element2:                // loop insert element part 1 into part 2
        sub x4,x8,1
        ldr w7,[x0,x8,lsl 2]       // load value 2
        cmp w6,w7                  // value <
        bge store_value2
        str w6,[x0,x4,lsl 2]       // store value 
        b second_section_advance2   // loop

    store_value2:
        str w7,[x0,x4,lsl 2]       // store value 2
        add x8,x8,1
        cmp w8,w3                  // end second section ?
        ble insert_element2         // no loop 
        sub x8,x8,1
        str w6,[x0,x8,lsl 2]       // store value 1

    second_section_advance2:
        add x1,x1,1
        cmp w1,w2                  // end first section ?
        blt first_section_loop2

    // Fusionando
    ADD x11, x11 , 1            // Incrementar el contador para imprimir
    bl print_array              // Llamar a la rutina para imprimir el arreglo

merge_return2:
    ldr x8,[sp],16             // restaur 1 register
    ldp x6,x7,[sp],16          // restaur 2 registers
    ldp x4,x5,[sp],16          // restaur 2 registers
    ldp x2,x3,[sp],16          // restaur 2 registers
    ldp x1,lr,[sp],16          // restaur 2 registers
    ret                        // return to address lr x30



//Salida esperada:
Antes de ordenar: 10, 0, 1, 5, -1, 3
Dividiendo en: [10, 0, 1] y [5, -1, 3]
Antes de ordenar: 10, 0, 1
Dividiendo en: [10] y [0, 1]
Antes de ordenar: 0, 1
Dividiendo en: [0] y [1]
Fusionando: [0, 1]
Fusionando: [10, 0, 1]
Fusionando: [-1, 3]
Fusionando: [5, -1, 3]
Fusionando: [-1, 0, 1, 3, 5, 10]
Lista ordenada: [-1, 0, 1, 3, 5, 10]






