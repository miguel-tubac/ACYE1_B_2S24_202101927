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
    LDR x0, =array
    mov w1, 0
    LDR x2, =count
    LDR x2, [x2] // length => cantidad de numeros leidos del csv
    SUB x2,x2,1
    bl mergeSort

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


// Función Principal Merge Sort
mergeSort:
    STP x29, x30, [SP, -16]!      // Guardar Frame Pointer (x29) y Link Register (x30)
    MOV x29, SP                   // Actualizar Frame Pointer
    
    CMP w1, w2                    // Comparar low (w1) con high (w2)
    BGE mergeSortEnd              // Si low >= high, retornar
    
    // Dividir el arreglo en dos mitades
    ADD w3, w1, w2                // W3 = low + high
    ASR w3, w3, #1                // W3 = (low + high) / 2 (mitad)
    
    // Ordenar la primera mitad
    MOV w4, w1                    // Pasar el valor de low a w4
    MOV w5, w3                    // Pasar el valor de mid a w5
    BL mergeSort                  // Llamar recursivamente a mergeSort para [low, mid]

    // Ordenar la segunda mitad
    ADD w4, w3, #1                // W4 = mid + 1
    MOV w5, w2                    // Pasar el valor de high a w5
    BL mergeSort                  // Llamar recursivamente a mergeSort para [mid+1, high]
    
    // Mezclar las dos mitades ordenadas
    MOV w4, w1                    // Pasar el valor de low a w4
    MOV w5, w3                    // Pasar el valor de mid a w5
    MOV w6, w2                    // Pasar el valor de high a w6
    BL merge                      // Llamar a merge para combinar las dos mitades ordenadas
    
mergeSortEnd:
    LDP x29, x30, [SP], #16       // Restaurar Frame Pointer y Link Register
    RET                           // Retornar

// Función para combinar (merge) dos mitades ordenadas
merge:
    STP x29, x30, [SP, -16]!      // Guardar Frame Pointer (x29) y Link Register (x30)
    MOV x29, SP                   // Actualizar Frame Pointer
    
    // Parámetros:
    // x0 -> &arreglo (array)
    // W1 -> low
    // W2 -> mid
    // W3 -> high

    // Tamaños de las mitades
    ADD w4, w2, #1                // Tamaño izquierda: mid - low + 1
    SUB w5, w3, w2                // Tamaño derecha: high - mid
    
    // Reservar espacio para los subarreglos izquierdo y derecho
    // Usaremos dos punteros temporales x7 y x8 para acceder a cada mitad
    // Creamos un buffer temporal para guardar los valores

    MOV w6, w1                    // Índice inicial para la primera mitad
    MOV w7, w4                    // Índice inicial para la segunda mitad
    MOV w8, w1                    // Índice de mezcla del arreglo final
    
mergeLoop:
    CMP w6, w2                    // Comparar índice izquierdo con mid
    BGT mergeRight                // Si índice izquierdo > mid, ir a mergeRight
    
    CMP w7, w3                    // Comparar índice derecho con high
    BGT mergeLeft                 // Si índice derecho > high, ir a mergeLeft
    
    // Comparar los elementos en cada subarreglo
    ADD x9, x0, x6, LSL #2        // Cargar valor de la primera mitad en w9
    LDR w9, [x9]
    ADD x10, x0, x7, LSL #2       // Cargar valor de la segunda mitad en w10
    LDR w10, [x10]
    
    CMP w9, w10                   // Comparar los valores
    BLE mergeLeft                 // Si el valor de la izquierda es menor o igual, ir a mergeLeft
    
    // Mezcla desde la derecha (valor más grande)
    ADD x11, x0, x8, LSL #2       // Posición de almacenamiento
    STR w10, [x11]                // Guardar valor de la derecha en el arreglo final
    ADD w7, w7, #1                // Incrementar índice derecho
    ADD w8, w8, #1                // Incrementar índice final
    B mergeLoop                   // Repetir el bucle
    
mergeLeft:
    ADD x11, x0, x8, LSL #2       // Posición de almacenamiento
    STR w9, [x11]                 // Guardar valor de la izquierda en el arreglo final
    ADD w6, w6, #1                // Incrementar índice izquierdo
    ADD w8, w8, #1                // Incrementar índice final
    B mergeLoop                   // Repetir el bucle

mergeRight:
    // Si solo quedan valores en el lado derecho
    CMP w7, w3                    // Comparar índice derecho con high
    BGT mergeEnd                  // Si hemos procesado todo, finalizar

    ADD x11, x0, x8, LSL #2       // Posición de almacenamiento
    LDR w10, [x10]                // Guardar valor de la derecha en el arreglo final
    STR w10, [x11]
    ADD w7, w7, #1                // Incrementar índice derecho
    ADD w8, w8, #1                // Incrementar índice final
    B mergeRight                  // Continuar con el lado derecho

mergeEnd:
    LDP x29, x30, [SP], #16       // Restaurar Frame Pointer y Link Register
    RET                           // Retornar







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





