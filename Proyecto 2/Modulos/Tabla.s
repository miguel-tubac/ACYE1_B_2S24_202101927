.global do_tabla

.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear

    salto:
        .asciz "\n"
        lenSalto = .- salto

    espacio:
        .asciz "\t"
        lenEspacio = .- espacio

    cols:
        .asciz "ABCDEFGHIJK"

    msgOpcion:
        .asciz "\nIngrese Un Comando: "
        lenOpcion = .- msgOpcion
    
    regresandoInicio:
        .asciz "\n...Presione enter para regresar..."
        lenRegresandoInicio = . - regresandoInicio

    datoGuardar:
        .asciz "GUARDAR A1 EN A2"
    
    cadena_exit:
        .asciz "#202101927-exit"
        lenCadExit = . -cadena_exit



.bss
    arreglo:
        .rept 276              // Reservar espacio para 276 valores de 64 bits  filas:23 columnas:12 =12*23
        .quad 0               // Inicializar cada valor con 0 (64 bits)
        .endr                 // Fin del bloque de repetición

    num:
        .space 4              // Reservar 4 bytes para almacenar un número

    val:
        .space 1              // Reservar 1 byte para almacenar un valor temporal
    
    opcion:
        .space 50   // => El 5 indica cuantos BYTES se reservaran para la variable opcion





.text

/* .macro print stdout, reg, len
    MOV x0, \stdout       // Colocar el descriptor de archivo (stdout) en x0
    LDR x1, =\reg         // Cargar la dirección del registro (reg) en x1
    MOV x2, \len          // Colocar la longitud del texto en x2
    MOV x8, 64            // Colocar el número de syscall para escribir en x8
    SVC 0                 // Hacer la syscall (escribir)
.endm*/

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


do_tabla:
    stp x29, x30, [sp, #-16]!    // Guardar el frame pointer y link register
    mov x29, sp                  // Establecer el frame pointer

    mostrarTabla:
        print clear, lenClear

        LDR x4, =arreglo      // Cargar la dirección de la matriz 'arreglo' en x4
        MOV x9, 0             // Inicializar el índice de slots en 0
        MOV x7, 0             // Inicializar el contador de filas en 0
        LDR x18, =cols        // Cargar la dirección de 'cols' en x18
        LDR x19, =val         // Cargar la dirección de 'val' en x19
        
        print val, 1       // Imprimir el valor en 'val'
        print espacio, lenEspacio  // Imprimir un espacio
        printCols:
            LDRB w20, [x18], 1    // Cargar el valor de 'cols' byte a byte
            STRB w20, [x19]       // Guardar el valor en 'val'

            print val, 1       // Imprimir el valor en 'val'
            print espacio, lenEspacio  // Imprimir un espacio
            ADD x7, x7, 1         // Incrementar el contador de filas
            CMP x7, 12            // Comparar el contador con 12
            BNE printCols         // Si no es igual, repetir el ciclo
            print salto, lenSalto  // Imprimir un salto de línea

        MOV x7, 0             // Reiniciar el contador de filas
        MOV x11, 0
        loop1:
            ADD x11,x11,1
            // Convertir dato del slot a ASCII
            MOV x0, x11   // Mover el valor en x11 a x0   el numeral de las filas 
            LDR x1, =num  // Cargar la dirección de 'num' en x1
            BL itoa       // Llamar a la función itoa para convertir a cadena
            print espacio, lenEspacio  // Imprimir un espacio
            MOV x13, 0        // Inicializar el contador de columnas en 0
            loop2:
                MOV x15, 0    // Inicializar x15 en 0
                LDR x15, [x4, x9, LSL #3]   // Cargar el valor del slot de la matriz en x15

                // Convertir dato del slot a ASCII
                MOV x0, x15   // Mover el valor en x15 a x0 (argumento para itoa)
                LDR x1, =num  // Cargar la dirección de 'num' en x1
                BL itoa       // Llamar a la función itoa para convertir a cadena

                print espacio, lenEspacio  // Imprimir un espacio

                ADD x9, x9, 1 // Incrementar el índice de slots
                ADD x13, x13, 1   // Incrementar el contador de columnas
                CMP x13, 11       // Comparar el contador con 11 (máximo de columnas)
                BNE loop2         // Si no es igual, repetir el ciclo de columnas

            print salto, lenSalto  // Imprimir un salto de línea

            ADD x9, x9, 1       // Incrementar el índice de slots
            ADD x7, x7, 1       // Incrementar el contador de filas
            CMP x7, 23          // Comparar el contador con 23 (cantidad de filas)
            BNE loop1           // Si no es igual, repetir el ciclo de filas
    

    print salto, lenSalto  // Imprimir un salto de línea
    print msgOpcion, lenOpcion
    read 0, opcion, 50

    // Remover el salto de línea (\n) de la cadena de entrada
    ldr x1, =opcion         // Cargar la dirección de la cadena ingresada
    mov x3, #0                   // Inicializar el índice

    remover_nueva_linea:
        ldrb w4, [x1, x3]            // Leer el carácter actual de la cadena
        cmp w4, #10                  // Comparar con el código ASCII de '\n' (10)
        beq poner_nulo               // Si es '\n', saltar a poner_nulo
        cmp w4, #0                   // Si es nulo, terminar
        //beq fin_remover_nueva_linea
        add x3, x3, #1               // Incrementar el índice
        b remover_nueva_linea        // Repetir

    poner_nulo:
        strb wzr, [x1, x3]           // Reemplazar '\n' con un carácter nulo

    //******************************** Guardar *******************************************************
    comparar_cadena_guardar:
        ldr x1, =opcion         // Cargar la dirección de la cadena ingresada
        ldr x2, =datoGuardar         // Cargar la dirección de la cadena "GUARDAR"
        mov x3, #0                   // Inicializar el índice
        
    comparar_ciclo_guardar:
        ldrb w4, [x1, x3]            // Cargar un carácter de la cadena ingresada
        ldrb w5, [x2, x3]            // Cargar el carácter correspondiente de "GUARDAR"
        cmp w4, w5                   // Comparar ambos caracteres
        bne no_coincide_guardar              // Si no coinciden, saltar a no_match
        cbz w4, conside_guardar              // Si llegamos al final de ambas cadenas (carácter nulo), son iguales
        add x3, x3, #1               // Incrementar el índice
        b comparar_ciclo_guardar              // Repetir el bucle

    conside_guardar:
        b mostrarTabla       

    no_coincide_guardar:
        b end
    //************************************* FIN GUARDAR *********************************************

    //b mostrarTabla
    //b end




end:
    // Mostrar el precionar enter
    print regresandoInicio, lenRegresandoInicio             // Tamaño de nueva línea
    ldp x29, x30, [sp], #16      // Restaurar el frame pointer y link register
    ret                          // Regresar al punto donde se llamó        












// Función para convertir un entero con la validación de signos a cadena ASCII
itoa:
    // params: x0 => number, x1 => buffer address
    MOV x10, 0  // contador de digitos a imprimir
    MOV x12, 0  // flag para indicar si hay signo menos

    CBZ x0, i_zero

    MOV x2, 1
    defineBase:
        CMP x2, x0
        MOV x5, 0
        BGT cont
        MOV x5, 10
        MUL x2, x2, x5
        B defineBase

    cont:
        CMP x0, 0  // Numero a convertir
        BGT i_convertirAscii
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
        NEG x0, x0

    i_convertirAscii:
        CBZ x2, i_endConversion
        UDIV x3, x0, x2
        CBZ x3, i_reduceBase

        MOV w5, w3
        ADD w5, w5, 48
        STRB w5, [x1], 1
        ADD x10, x10, 1

        MUL x3, x3, x2
        SUB x0, x0, x3

        CMP x2, 1
        BLE i_endConversion

        i_reduceBase:
            MOV x6, 10
            UDIV x2, x2, x6

            CBNZ x10, i_addZero
            B i_convertirAscii

        i_addZero:
            CBNZ x3, i_convertirAscii
            ADD x10, x10, 1
            MOV w5, 48
            STRB w5, [x1], 1
            B i_convertirAscii

    i_endConversion:
        ADD x10, x10, x12
        print num, x10
        RET




