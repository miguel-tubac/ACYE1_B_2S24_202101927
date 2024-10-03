.global do_bubble

.extern array
.extern count


.global bubbleSort
.global itoa
.global no_visualizar

.global bubbleSort_ConPasos
.global print_array

.global copy_array
.global copy_array2

.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear

    menuPrincipal:
        .asciz "------ Menu Bubble Sort ------\n"
        .asciz "1. Ordenamiento de manera Acendente\n"
        .asciz "2. Ordenamiento de manera Decendente\n"
        .asciz "3. Regresar..\n"
        lenMenuPrincipal = .- menuPrincipal

    msgOpcion:
        .asciz "\nIngrese Una Opcion: "
        lenOpcion = .- msgOpcion

    sumaComas:
        .asciz "\n...Ingresando Ordenamiento de manera Acendente...\n"
        lenMultiplicacionText = . - sumaComas

    cargacsv:
        .asciz "...Ingresando Ordenamiento de manera Decendente...\n"
        lencargacsv = . - cargacsv

    erronea:
        .asciz "\nOpción no válida, intenta de nuevo..."
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
    
    salto:
        .asciz "\n"
        lenSalto = .- salto
    
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
        .space 4

    filename:
        .zero 50
    
    opcion2:
        .space 5

    num1:
        .space 4

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
do_bubble:
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

            cmp w10,49
            beq bubbleSort_ConPasos

            b invalido

        decendente:
            bl copy_array2
            print cargacsv, lencargacsv
            // Imprimir mensaje para ingresar el nombre del archivo
            print visualizar, lenvisualizar              
            read 0, opcion, 2
            LDR x10, =opcion
            LDRB w10, [x10]

            /*cmp w10,48
            bl no_visualizar

            cmp w10,49
            bl si_visualizar*/
            
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
        ret                          // Regresar al punto donde se llamó


no_visualizar:
    bl bubbleSort
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




bubbleSort:
    LDR x0, =count          // Cargar la dirección de la variable count (número de elementos)
    LDR x0, [x0]            // Cargar el valor de count, es decir, la cantidad de números leídos del archivo CSV

    MOV x1, 0               // Inicializar índice i en 0 (este es el índice externo del algoritmo de ordenamiento burbuja)
    SUB x0, x0, 1           // Calcular length - 1, que es el número de pasadas necesarias para el algoritmo de burbuja

    bs_loop1:
        MOV x9, 0               // Inicializar índice j en 0 (este es el índice interno para comparar elementos adyacentes)
        SUB x2, x0, x1          // Calcular length - 1 - i, lo que reduce el rango de comparación en cada pasada

    bs_loop2:
        LDR x3, =array          // Cargar la dirección de la variable array (el arreglo de números)
        LDR w4, [x3, x9, LSL 2] // Cargar el valor de array[j] (primer número a comparar)

        ADD x9, x9, 1           // Incrementar el índice j en 1 para acceder al siguiente elemento
        LDR w5, [x3, x9, LSL 2] // Cargar el valor de array[j + 1] (segundo número a comparar)

        CMP w4, w5              // Comparar array[j] y array[j + 1]
        BLT bs_cont_loop2        // Si array[j] < array[j + 1], continuar sin intercambiar (ir a la siguiente iteración)

        STR w4, [x3, x9, LSL 2] // Intercambiar los elementos: almacenar array[j] en la posición array[j + 1]
        SUB x9, x9, 1           // Retroceder el índice j en 1 para corregir la posición
        STR w5, [x3, x9, LSL 2] // Almacenar array[j + 1] en la posición array[j]
        ADD x9, x9, 1           // Incrementar el índice j nuevamente para continuar la iteración

    bs_cont_loop2:
        CMP x9, x2              // Comparar si el índice j ha alcanzado el límite (length - 1 - i)
        BNE bs_loop2            // Si no ha alcanzado el límite, repetir el bucle interno (comparar siguiente par de elementos)

        ADD x1, x1, 1           // Incrementar el índice i para la siguiente pasada del algoritmo de burbuja
        CMP x1, x0              // Comparar si todas las pasadas necesarias han sido completadas
        BNE bs_loop1            // Si no se ha completado, repetir el bucle externo

        RET                     // Retornar de la función cuando el arreglo esté ordenado


bubbleSort_ConPasos:
    MOV x11, 0                      // Inicializar contador
    bl print_array           // Llamar a la rutina para imprimir el arreglo
    LDR x0, =count          // Cargar la dirección de la variable count (número de elementos)
    LDR x0, [x0]            // Cargar el valor de count, es decir, la cantidad de números leídos del archivo CSV

    MOV x1, 0               // Inicializar índice i en 0 (este es el índice externo del algoritmo de ordenamiento burbuja)
    SUB x0, x0, 1           // Calcular length - 1, que es el número de pasadas necesarias para el algoritmo de burbuja

    bs_loop11:
        MOV x9, 0               // Inicializar índice j en 0 (este es el índice interno para comparar elementos adyacentes)
        SUB x2, x0, x1          // Calcular length - 1 - i, lo que reduce el rango de comparación en cada pasada

    bs_loop22:
        LDR x3, =array          // Cargar la dirección de la variable array (el arreglo de números)
        LDR w4, [x3, x9, LSL 2] // Cargar el valor de array[j] (primer número a comparar)

        ADD x9, x9, 1           // Incrementar el índice j en 1 para acceder al siguiente elemento
        LDR w5, [x3, x9, LSL 2] // Cargar el valor de array[j + 1] (segundo número a comparar)

        CMP w4, w5              // Comparar array[j] y array[j + 1]
        BLT bs_cont_loop22        // Si array[j] < array[j + 1], continuar sin intercambiar (ir a la siguiente iteración)

        STR w4, [x3, x9, LSL 2] // Intercambiar los elementos: almacenar array[j] en la posición array[j + 1]
        SUB x9, x9, 1           // Retroceder el índice j en 1 para corregir la posición
        STR w5, [x3, x9, LSL 2] // Almacenar array[j + 1] en la posición array[j]
        ADD x9, x9, 1           // Incrementar el índice j nuevamente para continuar la iteración

    bs_cont_loop22:
        CMP x9, x2              // Comparar si el índice j ha alcanzado el límite (length - 1 - i)
        BNE bs_loop22            // Si no ha alcanzado el límite, repetir el bucle interno (comparar siguiente par de elementos)

        ADD x11, x11 , 1
        bl print_array           // Llamar a la rutina para imprimir el arreglo
        
        ADD x1, x1, 1           // Incrementar el índice i para la siguiente pasada del algoritmo de burbuja
        CMP x1, x0              // Comparar si todas las pasadas necesarias han sido completadas
        BNE bs_loop11            // Si no se ha completado, repetir el bucle externo

        print newline, lennewline
        print precionarEnter, lenPrecionarEnter
        read 0, filename, 50
        b menuS



print_array:
    STP x29, x30, [sp, #-16]!      // Guardar Frame Pointer (x29) y Link Register (x30)
    MOV x29, sp                    // Actualizar el Frame Pointer al valor de sp
    STP x0, x1, [sp, #-16]!        // Guardar x0 y x1 en la pila
    STP x9, x10, [sp, #-16]!       // Guardar registros adicionales
    STP x2, x3, [sp, #-16]!        // Guardar x2 y x3 (usados para itoa)
    STP x4, x5, [sp, #-16]!        // Guardar x4 y x5 (si se usan en itoa o la rutina actual)

    LDR x14, =count                // Cargar el valor de count (número de elementos)
    LDR x14, [x14]                 // Leer cantidad de números leídos del CSV
    MOV x7, 0                      // Inicializar contador
    LDR x15, =array                // Cargar la dirección del array

    CMP x11, 0
    beq inciando

    print pasosim, lenpasosim
    MOV x0, x11
    LDR x1, =num1
    BL itoa                        // Llamada a itoa para convertir el número
    print num1, x10
    print dospuntos, lendospuntos
    b loop_array2

    inciando:
        print conjInicial, lenconjInicial

    loop_array2:
        LDR w0, [x15], 4               // Cargar siguiente valor del array (elemento de 32 bits)
        LDR x1, =num                   // Apuntar el buffer a la cadena "num"

        BL itoa                        // Llamada a itoa para convertir el número
        print num, x10
        print espacio, lenEspacio      // Imprimir espacio entre los números

        ADD x7, x7, 1                  // Incrementar el contador
        CMP x14, x7                    // Comparar el contador con el número total
        BNE loop_array2                // Si no se ha terminado, repetir

        // Imprimir nueva línea
    print newline, lennewline

    LDP x4, x5, [sp], #16          // Restaurar x4 y x5
    LDP x2, x3, [sp], #16          // Restaurar x2 y x3
    LDP x9, x10, [sp], #16         // Restaurar x9 y x10
    LDP x0, x1, [sp], #16          // Restaurar x0 y x1
    LDP x29, x30, [sp], #16        // Restaurar Frame Pointer y Link Register

    ret                            // Retornar de la función


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

    RET  





