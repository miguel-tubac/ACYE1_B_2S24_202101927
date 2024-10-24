.global do_tabla


.extern do_Import
.extern do_Guardar
.extern do_suma
.extern do_resta
.extern do_multiplica
.extern do_divicion

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
        .asciz "GUARDAR"

    comando_importar:
        .asciz "IMPORTAR"
    
    comando_suma:
        .asciz "SUMA"

    comando_resta:
        .asciz "RESTA"
    
    comando_multiplicacion:
        .asciz "MULTIPLICACION"

    comando_dividir:
        .asciz "DIVIDIR"

    number64: 
        .word 1000000000  // Definir el número de 32 bits en memoria es decir hasta 10 cifras



.bss
    .global arreglo
    .global opcion
    .global retorno

    arreglo:
        .rept 276              // Reservar espacio para 276 valores de 64 bits  filas:23 columnas:12 =12*23
        .quad 0               // Inicializar cada valor con 0 (64 bits)
        .endr                 // Fin del bloque de repetición

    num:
        .space 8              // Reservar 4 bytes para almacenar un número

    val:
        .space 1              // Reservar 1 byte para almacenar un valor temporal
    
    opcion:
        .zero 50   // => El 50 indica cuantos BYTES se reservaran para la variable opcion

    retorno:
        .zero 1024//Esta es la variable de que guardara el retorno





.text

.macro print stdout, reg, len
    MOV x0, \stdout       // Colocar el descriptor de archivo (stdout) en x0
    LDR x1, =\reg         // Cargar la dirección del registro (reg) en x1
    MOV x2, \len          // Colocar la longitud del texto en x2
    MOV x8, 64            // Colocar el número de syscall para escribir en x8
    SVC 0                 // Hacer la syscall (escribir)
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
        print 1, clear, lenClear

        LDR x4, =arreglo      // Cargar la dirección de la matriz 'arreglo' en x4
        MOV x9, 0             // Inicializar el índice de slots en 0
        MOV x7, 0             // Inicializar el contador de filas en 0
        LDR x18, =cols        // Cargar la dirección de 'cols' en x18
        LDR x19, =val         // Cargar la dirección de 'val' en x19
        
        print 1, val, 1       // Imprimir el valor en 'val'
        print 1, espacio, lenEspacio  // Imprimir un espacio
        printCols:
            LDRB w20, [x18], 1    // Cargar el valor de 'cols' byte a byte
            STRB w20, [x19]       // Guardar el valor en 'val'

            print 1, val, 1       // Imprimir el valor en 'val'
            print 1, espacio, lenEspacio  // Imprimir un espacio
            print 1, espacio, lenEspacio  // Imprimir un espacio
            ADD x7, x7, 1         // Incrementar el contador de filas
            CMP x7, 12            // Comparar el contador con 12
            BNE printCols         // Si no es igual, repetir el ciclo
            print 1, salto, lenSalto  // Imprimir un salto de línea

        MOV x7, 0             // Reiniciar el contador de filas
        MOV x11, 0
        loop1:
            ADD x11,x11,1
            // Convertir dato del slot a ASCII
            MOV x0, x11   // Mover el valor en x11 a x0   el numeral de las filas 
            LDR x1, =num  // Cargar la dirección de 'num' en x1
            BL itoa       // Llamar a la función itoa para convertir a cadena
            print 1, espacio, lenEspacio  // Imprimir un espacio
            MOV x13, 0        // Inicializar el contador de columnas en 0
            loop2:
                MOV x15, 0    // Inicializar x15 en 0
                LDR x15, [x4, x9, LSL #3]   // Cargar el valor del slot de la matriz en x15

                // Convertir dato del slot a ASCII
                MOV x0, x15   // Mover el valor en x15 a x0 (argumento para itoa)
                LDR x1, =num  // Cargar la dirección de 'num' en x1
                BL itoa       // Llamar a la función itoa para convertir a cadena

                print 1, espacio, lenEspacio  // Imprimir un espacio
                print 1, espacio, lenEspacio  // Imprimir un espacio

                ADD x9, x9, 1 // Incrementar el índice de slots
                ADD x13, x13, 1   // Incrementar el contador de columnas
                CMP x13, 11       // Comparar el contador con 11 (máximo de columnas)
                BNE loop2         // Si no es igual, repetir el ciclo de columnas

            print 1, salto, lenSalto  // Imprimir un salto de línea

            ADD x9, x9, 1       // Incrementar el índice de slots
            ADD x7, x7, 1       // Incrementar el contador de filas
            CMP x7, 23          // Comparar el contador con 23 (cantidad de filas)
            BNE loop1           // Si no es igual, repetir el ciclo de filas
    

    print 1, salto, lenSalto  // Imprimir un salto de línea
    print 1, msgOpcion, lenOpcion
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

        cmp w4, 32      //Aca se compara con un espacio en blanco y si si entonces ya se termino de leer GUARDAR
        BEQ conside_guardar //Salta a la validacion de importar

        cmp w4, w5                   // Comparar ambos caracteres
        bne no_coincide_guardar              // Si no coinciden, saltar a no_match

        cbz w4, conside_guardar              // Si llegamos al final de ambas cadenas (carácter nulo), son iguales
        add x3, x3, #1               // Incrementar el índice
        b comparar_ciclo_guardar              // Repetir el bucle

    conside_guardar:
        bl do_Guardar
        b mostrarTabla       

    no_coincide_guardar:
        b comparar_cadena_importar
    //************************************* FIN GUARDAR *********************************************

    //******************************** IMPORTAR *******************************************************
    comparar_cadena_importar:
        ldr x1, =opcion         // Cargar la dirección de la cadena ingresada
        ldr x2, =comando_importar         // Cargar la dirección de la cadena "IMPORTAR"
        mov x3, #0                   // Inicializar el índice
        
    comparar_ciclo_importar:
        ldrb w4, [x1, x3]            // Cargar un carácter de la cadena ingresada
        ldrb w5, [x2, x3]            // Cargar el carácter correspondiente de "IMPORT"

        cmp w4, 32      //Aca se compara con un espacio en blanco y si si entonces ya se termino de leer IMPORT
        BEQ conside_importar //Salta a la validacion de importar

        cmp w4, w5                   // Comparar ambos caracteres
        bne no_coincide_importar              // Si no coinciden, saltar a no_match

        cbz w4, conside_importar              // Si llegamos al final de ambas cadenas (carácter nulo), son iguales
        add x3, x3, #1               // Incrementar el índice
        b comparar_ciclo_importar              // Repetir el bucle

    conside_importar:
        bl do_Import //Salta al archivo ImportNum.s en donde se leen los datos y se almacenan en el array
        b mostrarTabla //Retornamos e implimimos la tabla con los datos actualizados

    no_coincide_importar:
        b comparar_cadena_suma
    //************************************* FIN IMPORTAR *********************************************

    //******************************** SUMA *******************************************************
    comparar_cadena_suma:
        ldr x1, =opcion         // Cargar la dirección de la cadena ingresada
        ldr x2, =comando_suma         // Cargar la dirección de la cadena "SUMA"
        mov x3, #0                   // Inicializar el índice
        
    comparar_ciclo_suma:
        ldrb w4, [x1, x3]            // Cargar un carácter de la cadena ingresada
        ldrb w5, [x2, x3]            // Cargar el carácter correspondiente de "SUMA"

        cmp w4, 32      //Aca se compara con un espacio en blanco y si si entonces ya se termino de leer SUMA
        BEQ conside_suma //Salta a la validacion

        cmp w4, w5                   // Comparar ambos caracteres
        bne no_coincide_suma              // Si no coinciden, saltar a no_match

        cbz w4, conside_suma              // Si llegamos al final de ambas cadenas (carácter nulo), son iguales
        add x3, x3, #1               // Incrementar el índice
        b comparar_ciclo_suma              // Repetir el bucle

    conside_suma:
        bl do_suma //Salta al archivo Suma.s en donde se leen los datos
        b mostrarTabla //Retornamos e implimimos la tabla con los datos actualizados

    no_coincide_suma:
        b comparar_cadena_resta 
    //************************************* FIN SUMA *********************************************

    //******************************** RESTA *******************************************************
    comparar_cadena_resta:
        ldr x1, =opcion         // Cargar la dirección de la cadena ingresada
        ldr x2, =comando_resta         // Cargar la dirección de la cadena "RESTA"
        mov x3, #0                   // Inicializar el índice
        
    comparar_ciclo_resta:
        ldrb w4, [x1, x3]            // Cargar un carácter de la cadena ingresada
        ldrb w5, [x2, x3]            // Cargar el carácter correspondiente de "RESTA"

        cmp w4, 32      //Aca se compara con un espacio en blanco y si si entonces ya se termino de leer RESTA
        BEQ conside_resta //Salta a la validacion

        cmp w4, w5                   // Comparar ambos caracteres
        bne no_coincide_resta              // Si no coinciden, saltar a no_match

        cbz w4, conside_resta              // Si llegamos al final de ambas cadenas (carácter nulo), son iguales
        add x3, x3, #1               // Incrementar el índice
        b comparar_ciclo_resta              // Repetir el bucle

    conside_resta:
        bl do_resta //Salta al archivo Resta.s en donde se leen los datos
        b mostrarTabla //Retornamos e implimimos la tabla con los datos actualizados

    no_coincide_resta:
        b comparar_cadena_multi
    //************************************* FIN RESTA *********************************************

    //******************************** MULTIPLICACION *******************************************************
    comparar_cadena_multi:
        ldr x1, =opcion         // Cargar la dirección de la cadena ingresada
        ldr x2, =comando_multiplicacion         // Cargar la dirección de la cadena "MULTIPLICACION"
        mov x3, #0                   // Inicializar el índice
        
    comparar_ciclo_multi:
        ldrb w4, [x1, x3]            // Cargar un carácter de la cadena ingresada
        ldrb w5, [x2, x3]            // Cargar el carácter correspondiente de "MULTIPLICACION"

        cmp w4, 32      //Aca se compara con un espacio en blanco y si si entonces ya se termino de leer MULTIPLICACION
        BEQ conside_multi //Salta a la validacion

        cmp w4, w5                   // Comparar ambos caracteres
        bne no_coincide_multi              // Si no coinciden, saltar a no_match

        cbz w4, conside_multi              // Si llegamos al final de ambas cadenas (carácter nulo), son iguales
        add x3, x3, #1               // Incrementar el índice
        b comparar_ciclo_multi              // Repetir el bucle

    conside_multi:
        bl do_multiplica //Salta al archivo Multiplicacion.s en donde se leen los datos
        b mostrarTabla //Retornamos e implimimos la tabla con los datos actualizados

    no_coincide_multi:
        b comparar_cadena_div 
    //************************************* FIN MULTIPLICACION *********************************************

    //******************************** DIVIDIR *******************************************************
    comparar_cadena_div:
        ldr x1, =opcion         // Cargar la dirección de la cadena ingresada
        ldr x2, =comando_dividir         // Cargar la dirección de la cadena "DIVIDIR"
        mov x3, #0                   // Inicializar el índice
        
    comparar_ciclo_div:
        ldrb w4, [x1, x3]            // Cargar un carácter de la cadena ingresada
        ldrb w5, [x2, x3]            // Cargar el carácter correspondiente de "DIVIDIR"

        cmp w4, 32      //Aca se compara con un espacio en blanco y si si entonces ya se termino de leer DIVIDIR
        BEQ conside_div //Salta a la validacion

        cmp w4, w5                   // Comparar ambos caracteres
        bne no_coincide_div              // Si no coinciden, saltar a no_match

        cbz w4, conside_div              // Si llegamos al final de ambas cadenas (carácter nulo), son iguales
        add x3, x3, #1               // Incrementar el índice
        b comparar_ciclo_div              // Repetir el bucle

    conside_div:
        bl do_divicion //Salta al archivo Multiplicacion.s en donde se leen los datos
        b mostrarTabla //Retornamos e implimimos la tabla con los datos actualizados

    no_coincide_div:
        b end 
    //************************************* FIN DIVIDIR *********************************************




end:
    // Mostrar el precionar enter
    print 1, regresandoInicio, lenRegresandoInicio             // Tamaño de nueva línea
    ldp x29, x30, [sp], #16      // Restaurar el frame pointer y link register
    ret                          // Regresar al punto donde se llamó  






//******************************Aca se encuentra el area de conversio de entero a text y texto a entero */

itoa:
    // params: x0 => number (el número a convertir), x1 => buffer address (la dirección del buffer donde se almacenará la cadena)
    MOV x10, 0      // Inicializa el contador de dígitos a 0
    MOV x12, 0      // Inicializa la bandera para indicar si hay un signo negativo a 0
    //MOV w2, 10000   // Establece la base en 10^4 (para manejar hasta 5 dígitos)
    ldr w2, =number64
    ldr w2, [x2]
    CMP w0, 0       // Compara el número a convertir con 0
    BGT i_convertirAscii  // Si el número es positivo, salta a la conversión ASCII
    CBZ w0, i_zero  // Si el número es 0, salta al manejo de 0

    B i_negative    // Si el número es negativo, salta al manejo de número negativo

    i_zero:
        ADD x10, x10, 1     // Incrementa el contador de dígitos en 1
        MOV w5, 48          // Carga el valor ASCII de '0' en w5
        STRB w5, [x1], 1    // Almacena el carácter '0' en el buffer
        B i_endConversion   // Salta al final de la conversión

    i_negative:
        MOV x12, 1          // Establece la bandera de signo negativo en 1
        MOV w5, 45          // Carga el valor ASCII de '-' en w5
        STRB w5, [x1], 1    // Almacena el carácter '-' en el buffer
        NEG w0, w0          // Convierte el número a su valor positivo

    i_convertirAscii:
        CBZ w2, i_endConversion  // Si la base es 0, termina la conversión
        UDIV w3, w0, w2          // Divide el número por la base actual
        CBZ w3, i_reduceBase     // Si el cociente es 0, reduce la base y continúa

        MOV w5, w3           // Mueve el resultado de la división a w5
        ADD w5, w5, 48       // Convierte el dígito a su valor ASCII
        STRB w5, [x1], 1     // Almacena el dígito en el buffer
        ADD x10, x10, 1      // Incrementa el contador de dígitos

        // Si hemos impreso 5 dígitos, agregamos '!'
        CMP x10, 5
        BGT i_addExclamation

        MUL w3, w3, w2       // Multiplica el cociente por la base para restar el dígito
        SUB w0, w0, w3       // Resta el valor del dígito del número original

        CMP w2, 1            // Compara la base con 1
        BLE i_endConversion   // Si la base es 1 o menor, termina la conversión

    i_reduceBase:
        MOV w6, 10           // Establece el divisor de base en 10
        UDIV w2, w2, w6      // Reduce la base dividiéndola entre 10

        CBNZ x10, i_addZero  // Si el contador de dígitos no es 0, agrega un cero
        B i_convertirAscii   // Vuelve a convertir el siguiente dígito

    i_addZero:
        CBNZ w3, i_convertirAscii // Si el valor no es 0, convierte el siguiente dígito
        ADD x10, x10, 1      // Incrementa el contador de dígitos
        MOV w5, 48           // Carga el valor ASCII de '0' en w5
        STRB w5, [x1], 1     // Almacena el carácter '0' en el buffer
        B i_convertirAscii   // Continúa con la conversión de ASCII

    // Si ya hemos impreso 5 dígitos, agregamos '!' y terminamos la conversión
    i_addExclamation:
        MOV w5, 33      // '!'
        STRB w5, [x1,-1] //Carga el simbolo ! en la posicion adecuada
        ADD x10, x10, 1      // Incrementa el contador de dígitos
        B i_endConversion

    i_endConversion:
        ADD x10, x10, x12    // Agrega el signo negativo al contador de dígitos si es necesario
        print 1, num, x10    // Imprime el número convertido (usando algún mecanismo de impresión)

        RET                  // Retorna de la función


