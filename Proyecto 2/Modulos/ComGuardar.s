.global do_Guardar

.extern arreglo
.extern opcion



.data
    salto:
        .asciz "\n"
        lenSalto = .- salto

    cols:
        .asciz "ABCDEFGHIJK"

    datoGuardar:
        .asciz "GUARDAR"

    datoEn:
        .asciz "EN"

    errorImport:
        .asciz "Error en el Comando De GUARDAR"
        lenError = .- errorImport
    
    errorGeneral:
        .asciz "Error en la parte de la Fila o Columna"
        lenErrorGeneral = .-errorGeneral
    
    readSuccess:
        .asciz "El número se ha leido Correctamente\n"
        lenReadSuccess = .- readSuccess
    


.bss
    num:
        .space 10

    numeroCelda:
        .space 100

    numeroCeldaDestino:
        .space 100

    character:
        .space 2

    num2:
        .space 10


.text 
.macro print stdout, reg, len
    MOV x0, \stdout
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

.macro read stdin, reg, len
    MOV x0, \stdin
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm



//Menu principal de Guardar
do_Guardar:
    stp x29, x30, [sp, #-16]!    // Guardar el frame pointer y link register
    mov x29, sp                  // Establecer el frame pointer

    BL reset_variables//Se reinician las variables utilizadas

    BL proc_import//Aca se captura la celda origen o numero a la celda destino

    BL cargar_numero//Aca se evalua la sigueinte estructura: GUARDAR 155 EN A23

    ldp x29, x30, [sp], #16      // Restaurar el frame pointer y link register
    ret                          // Regresar al punto donde se llamó  




//Esta funcion realiza el reconocimiento del comando: GUARDAR <Número o celda> EN <Celda>
//<Celda>  Ejmplo: C13
//numeroCelda = <Número o celda>
//numeroCeldaDestino = <Celda>
proc_import:
    LDR x0, =datoGuardar //Aca se encuantra el comando GUARDAR
    LDR x1, =opcion //Aca se carga un bufer de 50 bytes

    imp_loop:
        LDRB w2, [x0], 1 //Se carga el primer caracter de GUARDAR
        LDRB w3, [x1], 1 //Se carga un caracter del bufercomand

        CBZ w2, imp_filename //Comparar y saltar si es cero, es decir un espacio en blanco

        CMP w2, w3
        BNE imp_error //  saltar si NO es igual w2 con w3

        B imp_loop //Si todo lo anterior no se cumple repite el ciclo

        imp_error: //Aca se imprime un error por si el comando GUARDAR no esta bien escrito
            print 1, errorImport, lenError //Imprime el mensaje de error
            B end_proc_import //Finaliza la funcion de reconocer el comando GUARDAR

    imp_filename: //Esta etiqueta obtiene el nombre de la etiqueta o el valor numerico
        LDR x0, =numeroCelda //Carga la direccion del buffer donde se almacena el valor de la celda 
        imp_file_loop:
            LDRB w2, [x1], 1 //Carga el primer bite del nombre del archivo

            CMP w2, 32 //Comparamos con el caracter de espacio en blanco
            BEQ cont_imp_file //saltar si es igual al bite a un espacio en blanco

            STRB w2, [x0], 1 //Carga el bite del nombre a la variable numeroCelda
            B imp_file_loop //Regresa al bucle hasta que se encuentre un espacio en blanco

        cont_imp_file: //Aca se compara el final de la cadena para ver si el comando final es correcto
            //Aca se compara si la cadena es: EN
            STRB wzr, [x0]//Carga el valor de cero al numeroCelda
            LDR x0, =datoEn //Caraga la palabra: EN
            comparar_tabulador:
                LDRB w2, [x0], 1 //Carga la primera letre de: EN
                LDRB w3, [x1], 1 //Se carga el primer valor del bufer de entrada

                CBZ w2, obtener_destino //Comparar y saltar si es cero el caracter de w2
                B comparar_tabulador //De lo contrario repite el bucle

                CMP w2, w3
                BNE imp_error //Saltar si NO es igual w2 con w3

        obtener_destino:
            //Aca obtenemos el valo de destino la celda final
            LDR x0, =numeroCeldaDestino //Carga la direccion del buffer donde se almacena el valor de la celda destino
            destino_loop:
                LDRB w2, [x1], 1 //Carga el primer bite de la celda destino

                CMP w2, 10 //Comparamos con el caracter de salto de linea
                BEQ poner_nulo //saltar si es igual al bite a un salto de linea

                CBZ w2, end_proc_import

                STRB w2, [x0], 1 //Carga el bite del nombre a la variable numeroCeldaDestino
                B destino_loop //Regresa al bucle hasta que se encuentre un salto de linea

        poner_nulo:
        STRB WZR, [x0, -1]           // Reemplazar '\n' con un carácter nulo
        
    end_proc_import://Llegamos al final de la cadena
        RET//Retornamos a la rutina donde fue llamada






cargar_numero:
    LDR x10, =num               // Cargar la dirección de 'num' en el registro x10
    LDR x11,  =numeroCelda    // Cargar la dirección de 'numeroCelda' en x11
    LDR x21, =num2                  // Inicializar el contador de filas en 0
    MOV X15, 0                   // Inicializar el contador de columnas en 0
    LDR x17, =numeroCeldaDestino

    rd_num:
        LDRB w3, [x11], 1           // Cargar el byte de 'character' en el registro w3

        CBZ w3, obtener_columna  // Si w3 es 0 (cadena vacía), saltar a 'obtener_columna'
        
        CMP w3,45
        BEQ continuar_negativo 

        CMP w3, 48              // Comparar si el carácter es el numero 1
        blt error_numero        // Si es menor que '1', es un error

        CMP w3, 57              // Comparar si el numero 9
        bgt error_numero        // Si es mayor que 9 es un error

        continuar_negativo:
            STRB w3, [x10], 1       // Almacenar el carácter leído en la dirección de 'num' y avanzar el puntero
            B rd_num                // Volver a leer el siguiente carácter

    error_numero:
        //Aca retornamos para validar la sigueinte validacion en donde la entrada es Una direccion de celda
        RET

    //Aca se obtine la direccion de la celda en donde se almacenara el numero anteriomente guardado en num:
    obtener_columna:
        LDRB w3, [x17], 1

        CMP w3, 65              // Comparar si el carácter es la letra A
        blt error_columna        // Si es menor que 'A', es un eroor

        CMP w3, 75              // Comparar si el carácter es la letra K
        bgt error_columna       // Si es mayor que 'K', es inválido' 

        SUB w15, w3, 65         //Como vamos a trabajar con las Columnas como letras A=65, por eso se le resta a la letra que venga
        B calcular_fila         // Volver a leer el siguiente carácter de las filas


    error_columna:
        print 1, errorGeneral, lenErrorGeneral //Imprime el error de fila o columna
        read 0, character, 2    // Leer dos caracteres de entrada
        RET
    
    calcular_fila: 
        LDRB w3, [x17], #1   // Cargar el byte de 'character' en el registro w3, avanzar x17 en 1 byte

        CBZ w3, rd_cv_num    // Si w3 es 0 (cadena vacía), saltar a 'rd_cv_num'

        CMP w3, 48              // 
        blt error_columna        // 

        CMP w3, 57              // 
        bgt error_columna    

        STRB w3, [x21], 1
        B calcular_fila      // Repite el ciclo hasta encontrar un valor nulo 0


    rd_cv_num:
        LDR x5, =num2            // Cargar la dirección de 'num' en x5
        LDR x8, =num2            // Cargar la dirección de 'num' en x8

        STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
        BL atoi                 // Llamar a la función 'atoi' para convertir la cadena numérica
        LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila
        MOV x21,x9
        SUB x21,x21,1

        LDR x5, =num            // Cargar la dirección de 'num' en x5
        LDR x8, =num            // Cargar la dirección de 'num' en x8

        STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
        BL atoi                 // Llamar a la función 'atoi' para convertir la cadena numérica
        LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

        //LDRB w16, [x15], 1      // Obtener el valor de la columna desde 'listIndex'
        MOV x16, x15

        LDR x20, =arreglo       // Cargar la dirección del arreglo donde se almacenan los datos
        MOV x22, 12              // Multiplicar la fila actual por 12 (supuesto tamaño de las filas)
        MUL x22, x21, x22       // Realizar la multiplicación para calcular el offset
        ADD x22, x16, x22       // Sumar el valor de la columna al offset
        STR x9, [x20, x22, LSL #3] // Almacenar el valor en el arreglo, ajustando el offset según el tamaño

    rd_end:
        print 1, salto, lenSalto // Imprimir un salto de línea
        print 1, readSuccess, lenReadSuccess // Imprimir el mensaje de éxito en la lectura
        read 0, character, 2    // Leer dos caracteres de entrada
        RET                     // Retornar del procedimiento







/*cargar_numero:
    LDR x10, =num               // Cargar la dirección de 'num' en el registro x10
    LDR x11,  =numeroCelda    // Cargar la dirección de 'numeroCelda' en x11
    LDR x11, [x11]              // Cargar el valor de 'numeroCelda' en x11
    MOV x21, 0                  // Inicializar el contador de filas en 0
    MOV X15, 0                   // Inicializar el contador de columnas en 0

    rd_num:
        read x11, character, 1  // Leer un carácter desde 'numeroCelda' en 'character'
        LDR x4, =character      // Cargar la dirección de 'character' en x4
        LDRB w3, [x4]           // Cargar el byte de 'character' en el registro w3

        CBZ w3, rd_cv_num       // Si w3 es 0 (cadena vacía), saltar a 'rd_cv_num'

        CMP w3, 10              // Comparar si el carácter es un salto de línea (newline)
        BEQ poner_nulo           // Si es newline, saltar a 'rd_cv_num'

        CMP w3, 65              // Comparar si el carácter es la letra A
        blt continuacion        // Si es menor que 'A', es un numero y continua y se guarda el valor en num

        CMP w3, 75              // Comparar si el carácter es la letra K
        bgt rd_cv_num           // Si es mayor que 'K', es inválido' , pendiente de validar

        calcular_columna:
            SUB w15, w3, 65         //Como vamos a trabajar con las Columnas como letras A=65, por eso se le resta a la letra que venga
            B calcular_fila         // Volver a leer el siguiente carácter de las filas

        continuacion:
            STRB w3, [x10], 1       // Almacenar el carácter leído en la dirección de 'num' y avanzar el puntero
            B rd_num                // Volver a leer el siguiente carácter
    
    poner_nulo:
        STRB WZR, [x10, -1]           // Reemplazar '\n' con un carácter nulo
        b rd_cv_num

    calcular_fila:
        read x11, character, 1  // Leer un carácter desde 'numeroCelda' en 'character'
        LDR x4, =character      // Cargar la dirección de 'character' en x4
        LDRB w3, [x4]           // Cargar el byte de 'character' en el registro w3

        CBZ w3, rd_cv_num       // Si w3 es 0 (cadena vacía), saltar a 'rd_cv_num'

        CMP w3, 10              // Comparar si el carácter es un salto de línea (newline)
        BEQ poner_nulo           // Si es newline, saltar a 'rd_cv_num'

        STRB w3, [x21], 1 //Almacena bit a bit el numero de la fila
        B calcular_fila //Repite el ciclo hasta encontrar un valor nulo 0


    rd_cv_num:
        LDR x5, =num            // Cargar la dirección de 'num' en x5
        LDR x8, =num            // Cargar la dirección de 'num' en x8

        STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
        BL atoi                 // Llamar a la función 'atoi' para convertir la cadena numérica
        LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

        LDRB w16, [x15], 1      // Obtener el valor de la columna desde 'listIndex'

        LDR x20, =arreglo       // Cargar la dirección del arreglo donde se almacenan los datos
        MOV x22, 12              // Multiplicar la fila actual por 12 (supuesto tamaño de las filas)
        MUL x22, x21, x22       // Realizar la multiplicación para calcular el offset
        ADD x22, x16, x22       // Sumar el valor de la columna al offset
        STR x9, [x20, x22, LSL #3] // Almacenar el valor en el arreglo, ajustando el offset según el tamaño

        LDR x12, =num           // Cargar la dirección de 'num' en x12
        MOV w13, 0              // Inicializar w13 en 0
        MOV x14, 0              // Inicializar x14 en 0
        
        LDR x20, =listIndex     // Cargar la dirección de 'listIndex' en x20
        SUB x20, x15, x20       // Restar el índice actual de 'listIndex'
        CMP x20, x17            // Comparar con el valor en x17 (tamaño esperado de columnas)
        BNE cls_num             // Si no son iguales, saltar a 'cls_num'

        LDR x15, =listIndex     // Reiniciar el índice de columnas
        ADD x21, x21, 1         // Incrementar el contador de filas

    cls_num:
        STRB w13, [x12], 1      // Almacenar 0 en la dirección de 'num'
        ADD x14, x14, 1         // Incrementar x14 en 1 (contador de ceros añadidos)
        CMP x14, 9              // Comparar si x14 ha alcanzado 7
        BNE cls_num             // Si no ha alcanzado 7, seguir limpiando
        LDR x10, =num           // Reiniciar el puntero de 'num'
        CBNZ x25, rd_num        // Si x25 no es 0, volver a 'rd_num' para leer más caracteres

    rd_end:
        print 1, salto, lenSalto // Imprimir un salto de línea
        print 1, readSuccess, lenReadSuccess // Imprimir el mensaje de éxito en la lectura
        read 0, character, 2    // Leer dos caracteres de entrada
        RET                     // Retornar del procedimiento*/



// Función para convertir cadena ASCII a un entero con la validación de signos
atoi:  
    // params: x5, x8 => buffer address
    SUB x5, x5, 1                     // Restar 1 a x5 para ajustar el puntero a la última posición del buffer
    a_c_digits:
        LDRB w7, [x8], 1              // Cargar el siguiente byte del buffer en w7, y luego incrementar x8
        CBZ w7, a_c_convert            // Si w7 es 0 (fin de cadena), saltar a la conversión
        CMP w7, 10                     // Comparar w7 con el carácter de nueva línea (valor ASCII 10)
        BEQ a_c_convert                // Si w7 es nueva línea, saltar a la conversión
        B a_c_digits                   // Si no es nueva línea, repetir el ciclo para el siguiente carácter

    a_c_convert:
        SUB x8, x8, 2                 // Retroceder el puntero de x8 dos posiciones para la conversión
        MOV x4, 1                     // Inicializar x4 en 1 para la multiplicación de lugar decimal
        MOV w9, 0                     // Inicializar el acumulador x9 en 0 para almacenar el resultado final

        a_c_loop:
            LDRB w7, [x8], -1         // Cargar el byte actual en w7 y decrementar x8 (lectura en orden inverso)
            CMP w7, 45                // Comparar el byte con el carácter '-' (valor ASCII 45)
            BEQ a_c_negative           // Si es '-', saltar a la conversión a negativo

            SUB w7, w7, 48            // Convertir el carácter ASCII a su valor numérico (restando 48)
            MUL w7, w7, w4            // Multiplicar el dígito por el lugar decimal (x4)
            ADD w9, w9, w7            // Sumar el valor calculado a x9 (acumulador)

            MOV w6, 10                // Cargar 10 en w6
            MUL w4, w4, w6            // Multiplicar x4 por 10 para ajustar el lugar decimal

            CMP x8, x5                // Comparar el puntero actual x8 con el inicial x5
            BNE a_c_loop              // Si no son iguales, continuar el bucle

            B a_c_end                 // Si ya terminó el ciclo, saltar al final

        a_c_negative:
            NEG w9, w9                // Si había un signo negativo, convertir el valor acumulado en negativo

        a_c_end:
            RET                       // Retornar el valor convertido (almacenado en w9)



reset_variables:
    // Reiniciar 'num' (10 bytes)
    LDR x0, =num               // Dirección base de 'num'
    MOV x1, #10                // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

    // Reiniciar 'numeroCelda' (100 bytes)
    LDR x0, =numeroCelda      // Dirección base de 'numeroCelda'
    MOV x1, #100               // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

    // Reiniciar 'numeroCeldaDestino' (100 bytes)
    LDR x0, =numeroCeldaDestino // Dirección base de 'numeroCeldaDestino'
    MOV x1, #100               // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

    // Reiniciar 'character' (2 bytes)
    LDR x0, =character         // Dirección base de 'character'
    MOV x1, #2                 // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

    // Reiniciar 'num2' (10 bytes)
    LDR x0, =num2              // Dirección base de 'num2'
    MOV x1, #10                // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

    RET                        // Regresar de la función

    // Función para limpiar memoria
    clear_memory:
        // params: x0 => dirección, x1 => tamaño en bytes
        CBZ x1, end_clear_memory   // Si tamaño es 0, salir

        mov x2, 0                  // Valor a establecer (0)

    .clear_loop:
        STRB w2, [x0], 1           // Almacena 0 en la dirección y avanza
        SUBS x1, x1, 1             // Decrementa el contador
        BNE .clear_loop            // Repetir hasta que x1 sea 0

    end_clear_memory:
        RET                        // Regresar de la función






