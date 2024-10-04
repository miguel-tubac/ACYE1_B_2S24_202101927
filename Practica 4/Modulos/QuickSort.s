.global do_quick

.extern array
.extern count
.global qsort

//.global copy_array
//.global copy_array2
//.global itoa

.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear

    menuPrincipal:
        .asciz "¬¬¬¬¬¬¬¬¬ Menu Quick Sort ¬¬¬¬¬¬¬¬¬\n"
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
do_quick:
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
        // Mostrar el precionar enter
        mov x0, 1              // Descriptor de archivo para stdout
        ldr x1, =regresandoInicio       // Dirección de nueva línea
        mov x2, lenRegresandoInicio             // Tamaño de nueva línea
        mov x8, 64             // Número de llamada al sistema para write
        svc 0                  // Llamada al sistema

        ldp x29, x30, [sp], #16      // Restaurar el frame pointer y link register
        ret



//***************************************** Inicio del quick**************
no_visualizar:
    /*LDR x0, =array
    LDR x1, =count
    LDR x1, [x1] // length => cantidad de numeros leidos del csv*/
    bl qsort
    //bl bubbleSort_desendente
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







qsort:
    STP x29, x30, [sp, #-16]!      // Guardar Frame Pointer (x29) y Link Register (x30)
    MOV x29, sp                    // Actualizar el Frame Pointer al valor de sp
    // Cargar la dirección de la variable 'count' (número de elementos)
    LDR x0, =count          
    LDR x0, [x0]            // Cargar el valor de count (cantidad de números)
    MOV x1, 0               // Inicializar índice bajo (low = 0)
    SUB x0, x0, 1           // Calcular el índice alto (high = count - 1)
    
    // Llamar a la función recursiva de QuickSort con los parámetros: (low, high)
    BL quickSort_recursive
    LDP x29, x30, [sp], #16        // Restaurar Frame Pointer y Link Register
    RET                     // Retornar cuando el arreglo esté completamente ordenado


// quickSort_recursive: Función recursiva QuickSort
// Parámetros: x0 = índice bajo (low), x1 = índice alto (high)
quickSort_recursive:
    STP x29, x30, [sp, #-16]!      // Guardar Frame Pointer (x29) y Link Register (x30)
    MOV x29, sp                    // Actualizar el Frame Pointer al valor de sp
    CMP x0, x1              // Si low >= high, retornar (base de la recursión)
    BGE quickSort_return

    // Llamar a la función partition con los parámetros: (low, high)
    MOV x2, x0              // Pasar 'low' a x2
    MOV x3, x1              // Pasar 'high' a x3
    BL partition            // partition devuelve el pivote en x0

    // Llamar recursivamente a quickSort_recursive en el lado izquierdo (low, pivot - 1)
    SUB x1, x0, 1           // pivot - 1
    BL quickSort_recursive   // Ordenar la parte izquierda

    // Llamar recursivamente a quickSort_recursive en el lado derecho (pivot + 1, high)
    ADD x0, x0, 1           // pivot + 1
    MOV x1, x3              // Restaurar el valor original de high
    BL quickSort_recursive   // Ordenar la parte derecha

    quickSort_return:
    LDP x29, x30, [sp], #16        // Restaurar Frame Pointer y Link Register
        RET


// partition: Función de partición
// Parámetros: x0 = índice bajo (low), x1 = índice alto (high)
// Retorno: x0 = índice del pivote después de la partición
partition:
    STP x29, x30, [sp, #-16]!      // Guardar Frame Pointer (x29) y Link Register (x30)
    MOV x29, sp                    // Actualizar el Frame Pointer al valor de sp
    LDR x2, =array          // Cargar la dirección base del arreglo

    // Seleccionar el pivote como el último elemento
    LDR w3, [x2, x1, LSL #2]    // pivote = array[high]

    // Inicializar i a low - 1
    SUB x4, x0, 1           // i = low - 1

    partition_loop:
        ADD x5, x0, x4          // j = low
        CMP x5, x1              // Comparar j con high
        BGE partition_end       // Si j >= high, salir del bucle

        // Cargar array[j]
        LDR w6, [x2, x0, LSL #2]    // array[j]

        // Comparar array[j] con el pivote
        CMP w6, w3
        BGT partition_skip       // Si array[j] > pivote, saltar

        // Incrementar i y hacer intercambio
        ADD x4, x4, 1           // i++
        LDR w7, [x2, x4, LSL #2]    // Cargar array[i]
        STR w6, [x2, x4, LSL #2]    // array[i] = array[j]
        STR w7, [x2, x0, LSL #2]    // array[j] = array[i]

    partition_skip:
        ADD x0, x0, 1           // j++
        B partition_loop        // Repetir el bucle

    partition_end:
        // Intercambiar array[i + 1] con array[high] (pivote)
        ADD x4, x4, 1           // i++
        LDR w7, [x2, x1, LSL #2]    // Cargar array[high]
        STR w3, [x2, x4, LSL #2]    // array[i + 1] = pivote
        STR w7, [x2, x1, LSL #2]    // array[high] = array[i + 1]

        // Retornar el índice del pivote
        MOV x0, x4              // Retornar i + 1
        LDP x29, x30, [sp], #16        // Restaurar Frame Pointer y Link Register
        RET




//******************************************* Fin del quick ********************



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


