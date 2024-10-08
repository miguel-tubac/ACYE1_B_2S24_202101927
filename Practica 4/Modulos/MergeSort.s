.global do_mergeSort

.extern array
.extern count


/*

El algoritmo de Merge Sort sigue una estrategia de "divide y vencerás", dividiendo el arreglo en mitades, ordenando cada mitad de 
manera recursiva, y luego combinando (o merge) los resultados ordenados.

 */
.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear

    menuPrincipal:
        .asciz "⇷⇷⇷⇷⇷⇷⇷ Menu Merge Sort ⇸⇸⇸⇸⇸⇸⇸\n"
        .asciz "1. Ordenamiento de manera Acendente\n"
        .asciz "2. Ordenamiento de manera Decendente\n"
        .asciz "3. Regresar..\n"
        lenMenuPrincipal = .- menuPrincipal

    msgOpcion:
        .asciz "\nIngrese Una Opcion: "
        lenOpcion = .- msgOpcion

    sumaComas:
        .asciz "...Ingresando Ordenamiento de manera Acendente...\n"
        lenMultiplicacionText = . - sumaComas

    cargacsv:
        .asciz "...Ingresando Ordenamiento de manera Decendente...\n"
        lencargacsv = . - cargacsv

    erronea:
        .asciz "\n...Opción no válida, intenta de nuevo..."
        lenErronea = . - erronea

    precionarEnter:
        .asciz "\n\n...Presione enter para continuar..."
        lenPrecionarEnter = . - precionarEnter

    regresandoInicio:
        .asciz "\n...Presione enter para regresar..."
        lenRegresandoInicio = . - regresandoInicio

    visualizar:
        .asciz "\nIngrese 1 si deceas ver los pasos y 0 si no: "
        lenvisualizar = . - visualizar
    
    espacio:
        .asciz " "
        lenEspacio = .- espacio
    
    newline:
        .asciz "\n"
        lennewline = . - newline

    resulta:
        .asciz "\nResultado: "
        lenResultado = . - resulta

    pasosim:
        .asciz "\nPaso "
        lenpasosim = . -pasosim

    dospuntos:
        .asciz " : "
        lendospuntos = . - dospuntos
    
    conjInicial: 
        .asciz "\nConjunto inicial: "
        lenconjInicial = . - conjInicial


.bss
    opcion:
        .space 5   // => El 5 indica cuantos BYTES se reservaran para la variable opcion
    num:
        .space 50

    filename:
        .zero 50
    
    opcion2:
        .space 5

    num1:
        .space 50

    array2:
        .skip 1024


// Macro para imprimir strings
.macro print reg, len
    MOV x0, 1
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

// Macro para leer datos del usuario
.macro read stdin, buffer, len
    MOV x0, \stdin
    LDR x1, =\buffer
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm


.text
do_mergeSort:
    stp x29, x30, [sp, #-16]!    // Guardar el frame pointer y link register
    mov x29, sp                  // Establecer el frame pointer

    bl copy_array
    menuS:
        print clear, lenClear
        print menuPrincipal, lenMenuPrincipal
        print msgOpcion, lenOpcion
        read 0, opcion, 2
        //input

        LDR x10, =opcion
        LDRB w10, [x10]

        /*// Imprimir el segundo mensaje
        mov x0, 1          // Descriptor de archivo para stdout
        ldr x1, =opcion   // Dirección del mensaje
        mov x2, #5        // Longitud del mensaje
        mov x8, 64         // Número de llamada al sistema para write
        svc 0              // Llamada al sistema*/

        cmp w10, 49
        beq acendente

        cmp w10, 50
        beq decendente

        cmp w10, 51
        beq end

        b invalido

        invalido:
            print erronea, lenErronea
            b cont

        acendente:
            bl copy_array2
            print sumaComas, lenMultiplicacionText
            //beq opcion_separados 
            
            print visualizar, lenvisualizar              
            read 0, opcion2, 2
            LDR x10, =opcion2
            LDRB w10, [x10]

            cmp w10,48
            beq no_visualizar

            //cmp w10,49
            //beq bubbleSort_ConPasos

            b invalido

        decendente:
            bl copy_array2
            print cargacsv, lencargacsv
            // Imprimir mensaje para ingresar el nombre del archivo
            print visualizar, lenvisualizar              
            read 0, opcion, 2
            LDR x10, =opcion
            LDRB w10, [x10]

            //cmp w10,48
            //beq no_visualizar1

            //cmp w10,49
            //beq bubbleSort_desendenteConPasos
            
            b invalido
        cont:
            read 0, filename, 50
            b menuS

    end:
        bl copy_array2//esto es para que el array original mantenga el valor con que se inicio
        // Mostrar el precionar enter
        mov x0, 1              // Descriptor de archivo para stdout
        ldr x1, =regresandoInicio       // Dirección de nueva línea
        mov x2, lenRegresandoInicio             // Tamaño de nueva línea
        mov x8, 64             // Número de llamada al sistema para write
        svc 0                  // Llamada al sistema

        ldp x29, x30, [sp], #16      // Restaurar el frame pointer y link register
        ret                          // Regresar al punto donde se llamó



//***************************************** Inicio del Merge Sort Acendete**************

no_visualizar:
    ldr x0, =array                        // address number table
    mov x1,0                                       // first element
    LDR x2, =count
    LDR x2, [x2] // length => cantidad de numeros leidos del csv
    //SUB x2,x2,1                              // number of élements 
    bl mergeSort

    // recorrer array y convertir a ascii
    LDR x9, =count
    LDR x9, [x9] // length => cantidad de numeros leidos del csv
    MOV x7, 0
    LDR x15, =array

    print resulta, lenResultado
    loop_array:
        LDR w0, [x15], 4
        LDR x1, =num
        BL itoa

        print num, x10
        print espacio, lenEspacio

        ADD x7, x7, 1
        CMP x9, x7
        BNE loop_array

    print newline, lennewline
    print precionarEnter, lenPrecionarEnter
    read 0, filename, 50
    b menuS




/******************************************************************/
/*         merge                                              */ 
/******************************************************************/
/* r0 contains the address of table */
/* r1 contains first start index
/* r2 contains second start index */
/* r3 contains the last index   */ 
merge:
    stp x1,lr,[sp,-16]!        // save  registers
    stp x2,x3,[sp,-16]!        // save  registers
    stp x4,x5,[sp,-16]!        // save  registers
    stp x6,x7,[sp,-16]!        // save  registers
    str x8,[sp,-16]!
    mov x5,x2                  // init index x2->x5 
first_section_loop:            // begin loop first section
    ldr w6,[x0,x1,lsl 2]       // load value first section index r1
    ldr w7,[x0,x5,lsl 2]       // load value second section index r5
    cmp w6,w7
    ble second_section_advance // <=  -> location first section OK
    str w7,[x0,x1,lsl 2]       // store value second section in first section
    add x8,x5,1
    cmp w8,w3                  // end second section ?
    ble insert_element
    str w6,[x0,x5,lsl 2]
    b second_section_advance   // loop
insert_element:                // loop insert element part 1 into part 2
    sub x4,x8,1
    ldr w7,[x0,x8,lsl 2]       // load value 2
    cmp w6,w7                  // value < 
    bge store_value
    str w6,[x0,x4,lsl 2]       // store value 
    b second_section_advance   // loop
store_value:
    str w7,[x0,x4,lsl 2]       // store value 2
    add x8,x8,1
    cmp w8,w3                  // end second section ?
    ble insert_element         // no loop 
    sub x8,x8,1
    str w6,[x0,x8,lsl 2]       // store value 1
second_section_advance:
    add x1,x1,1
    cmp w1,w2                  // end first section ?
    blt first_section_loop

merge_return:
    ldr x8,[sp],16             // restaur 1 register
    ldp x6,x7,[sp],16          // restaur  2 registers
    ldp x4,x5,[sp],16          // restaur  2 registers
    ldp x2,x3,[sp],16          // restaur  2 registers
    ldp x1,lr,[sp],16          // restaur  2 registers
    ret                        // return to address lr x30
/******************************************************************/
/*      merge sort                                                */ 
/******************************************************************/
/* x0 contains the address of table */
/* x1 contains the index of first element */
/* x2 contains the number of element */
mergeSort:
    stp x3,lr,[sp,-16]!    // save  registers
    stp x4,x5,[sp,-16]!    // save  registers
    stp x6,x7,[sp,-16]!    // save  registers
    cmp w2,2               // end ?
    blt merge_sort_end
    lsr x4,x2,1            // number of element of each subset
    add x5,x4,1
    tst x2,#1              // odd ?
    csel x4,x5,x4,ne
    mov x5,x1              // save first element
    mov x6,x2              // save number of element
    mov x7,x4              // save number of element of each subset
    mov x2,x4
    bl mergeSort
    mov x1,x7              // restaur number of element of each subset
    mov x2,x6              // restaur  number of element
    sub x2,x2,x1
    mov x3,x5              // restaur first element
    add x1,x1,x3           // + 1
    bl mergeSort           // sort first subset
    mov x1,x5              // restaur first element
    mov x2,x7              // restaur number of element of each subset
    add x2,x2,x1
    mov x3,x6              // restaur  number of element
    add x3,x3,x1 
    sub x3,x3,1            // last index
    bl merge
merge_sort_end:
    ldp x6,x7,[sp],16          // restaur  2 registers
    ldp x4,x5,[sp],16          // restaur  2 registers
    ldp x3,lr,[sp],16          // restaur  2 registers
    ret                        // return to address lr x30







//***************************************** Fin del Merge Sort Acendete**************



copy_array:
    // Asumimos que array y array2 tienen el mismo tamaño (1024 bytes)
    LDR x0, =array      // Cargar la dirección de 'array' en x0
    LDR x1, =array2     // Cargar la dirección de 'array2' en x1
    MOV x2, 1024        // Tamaño del array (1024 bytes)

    copy_loop:
        LDRB w3, [x0], 1    // Cargar byte desde 'array' en w3 y avanzar x0
        STRB w3, [x1], 1    // Almacenar byte en 'array2' y avanzar x1
        SUBS x2, x2, 1      // Decrementar el contador de bytes
        BNE copy_loop       // Repetir hasta copiar todos los bytes

        // Fin de la rutina
        RET



copy_array2:
    // Asumimos que array y array2 tienen el mismo tamaño (1024 bytes)
    LDR x0, =array2      // Cargar la dirección de 'array2' en x0
    LDR x1, =array     // Cargar la dirección de 'array' en x1
    MOV x2, 1024        // Tamaño del array (1024 bytes)

    copy_loop2:
        LDRB w3, [x0], 1    // Cargar byte desde 'array2' en w3 y avanzar x0
        STRB w3, [x1], 1    // Almacenar byte en 'array' y avanzar x1
        SUBS x2, x2, 1      // Decrementar el contador de bytes
        BNE copy_loop2       // Repetir hasta copiar todos los bytes

        // Fin de la rutina
        RET


itoa:
    // params: x0 => number, x1 => buffer address
    MOV x10, 0  // contador de digitos a imprimir
    MOV x12, 0  // flag para indicar si hay signo menos
    MOV w2, 10000  // Base 10
    CMP w0, 0  // Numero a convertir
    BGT i_convertirAscii
    CBZ w0, i_zero

    B i_negative

    i_zero:
        ADD x10, x10, 1
        MOV w5, 48
        STRB w5, [x1], 1
        B i_endConversion

    i_negative:
        MOV  x12, 1
        MOV w5, 45
        STRB w5, [x1], 1
        NEG w0, w0

    i_convertirAscii:
        CBZ w2, i_endConversion
        UDIV w3, w0, w2
        CBZ w3, i_reduceBase

        MOV w5, w3
        ADD w5, w5, 48
        STRB w5, [x1], 1
        ADD x10, x10, 1

        MUL w3, w3, w2
        SUB w0, w0, w3

        CMP w2, 1
        BLE i_endConversion

        i_reduceBase:
            MOV w6, 10
            UDIV w2, w2, w6

            CBNZ w10, i_addZero
            B i_convertirAscii

        i_addZero:
            CBNZ w3, i_convertirAscii
            ADD x10, x10, 1
            MOV w5, 48
            STRB w5, [x1], 1
            B i_convertirAscii

    i_endConversion:
        ADD x10, x10, x12
        //print num, x10

    RET  //






















