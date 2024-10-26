.global do_minimo

.extern arreglo
.extern opcion
.extern retorno

.data
    salto:
        .asciz "\n"
        lenSalto = .- salto

    datoSuma:
        .asciz "MINIMO DESDE"

    datoY:
        .asciz "HASTA"

    errorImport:
        .asciz "Error en el Comando De MINIMO o en la letra HASTA"
        lenError = .- errorImport
    
    errorGeneral:
        .asciz "Error en la parte de la Fila o Columna de la Direccion Objetivo"
        lenErrorGeneral = .-errorGeneral
    
    readSuccess:
        .asciz "La operacion MINIMO se ha realizado Correctamente\n"
        lenReadSuccess = .- readSuccess

    errorColum:
        .asciz "Error en la Columna o Fila de la Direccion de Celda"
        lenerrorColum = .-errorColum

    errorNumero:
        .asciz "Error en el numero ingresado"
        lenerrorNumero = .-errorNumero

    errorCol:
        .asciz "\n...La columna INICIAL debe ser menor a la columna FINAL..."
        lenerrorCol = .- errorCol

    errorFila:
        .asciz "\n...La fila INICIAL y FINAL debe ser menor o igual a 23..."
        lenerrorFila = .-errorFila
    


.bss
    num:
        .space 10

    numeroCelda_1:
        .space 100

    numeroCelda_2:
        .space 100

    character:
        .space 2

    num2:
        .space 10
    
    num3:
        .space 10

    num4:
        .space 10

    num5:
        .space 10

    num6:
        .space 10

    valor:
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




do_minimo:
    stp x29, x30, [sp, #-16]!    // Guardar el frame pointer y link register
    mov x29, sp                  // Establecer el frame pointer

    BL reset_variables //Reiniciamos las varibles

    BL proc_import//Aca se captura la celda origen o numero a la celda destino

    BL cargar_referencia //Se carga el valor a la variable retorno

    ldp x29, x30, [sp], #16      // Restaurar el frame pointer y link register
    ret                          // Regresar al punto donde se llamó 





//Esta funcion realiza el reconocimiento del comando: SUMA <Número o celda> Y <Número o celda>
//<Celda>  Ejmplo: C13
//numeroCelda = <Número o celda>
//numeroCeldaDestino = <Celda>
proc_import:
    LDR x0, =datoSuma //Aca se encuantra el comando SUMA
    LDR x1, =opcion //Aca se carga un bufer de 50 bytes
    MOV x4, 0 //contador del espacio en blanco de la palabra LLENAR DESDE

    imp_loop:
        LDRB w2, [x0], 1 //Se carga el primer caracter de SUMA
        LDRB w3, [x1], 1 //Se carga un caracter del bufercomand

        cmp w2, 32      //Aca se compara con un espacio en blanco y si si entonces ya se termino de leer LLENAR
        BEQ espacio_extra //Salta a la validacion

        CBZ w2, espacio_extra //Comparar y saltar si es cero, es decir un espacio en blanco
        B continuacion //Si no es un espacio en blanco continua normal 
        espacio_extra:
            ADD x4, x4, 1 //incrementamos en una unidad
            CMP x4, 2 //compara con 2 ya que solo se aceptara un espacio en blanco
            BEQ imp_filename //Salta para obtener el dato 

        continuacion:
            CMP w2, w3
            BNE imp_error //  saltar si NO es igual w2 con w3

            B imp_loop //Si todo lo anterior no se cumple repite el ciclo

            imp_error: //Aca se imprime un error por si el comando SUMA no esta bien escrito
                print 1, errorImport, lenError //Imprime el mensaje de error
                B end_proc_import //Finaliza la funcion de reconocer el comando GUARDAR

    imp_filename: //Esta etiqueta obtiene el nombre de la etiqueta o el valor numerico
        LDR x0, =numeroCelda_1 //Carga la direccion del buffer donde se almacena el valor de la celda 
        imp_file_loop:
            LDRB w2, [x1], 1 //Carga el primer bite del nombre del archivo

            CMP w2, 32 //Comparamos con el caracter de espacio en blanco
            BEQ cont_imp_file //saltar si es igual al bite a un espacio en blanco

            STRB w2, [x0], 1 //Carga el bite del nombre a la variable numeroCelda
            B imp_file_loop //Regresa al bucle hasta que se encuentre un espacio en blanco

        cont_imp_file: //Aca se compara el final de la cadena para ver si el comando final es correcto
            //Aca se compara si la cadena es: Y
            STRB wzr, [x0]//Carga el valor de cero al numeroCelda
            LDR x0, =datoY //Caraga la palabra: EN
            comparar_tabulador:
                LDRB w2, [x0], 1 //Carga la primera letre de: EN
                LDRB w3, [x1], 1 //Se carga el primer valor del bufer de entrada

                CBZ w2, obtener_destino //Comparar y saltar si es cero el caracter de w2
                B comparar_tabulador //De lo contrario repite el bucle

                CMP w2, w3
                BNE imp_error //Saltar si NO es igual w2 con w3

        obtener_destino:
            //Aca obtenemos el valo de destino la celda final
            LDR x0, =numeroCelda_2 //Carga la direccion del buffer donde se almacena el valor de la celda destino
            destino_loop:
                LDRB w2, [x1], 1 //Carga el primer bite de la celda destino

                CMP w2, 10 //Comparamos con el caracter de salto de linea
                BEQ poner_nulo //saltar si es igual al bite a un salto de linea

                CBZ w2, end_proc_import

                STRB w2, [x0], 1 //Carga el bite del nombre a la variable numeroCelda_2
                B destino_loop //Regresa al bucle hasta que se encuentre un salto de linea

        poner_nulo:
        STRB WZR, [x0, -1]           // Reemplazar '\n' con un carácter nulo
        
    end_proc_import://Llegamos al final de la cadena
        RET//Retornamos a la rutina donde fue llamada






//Aca se evalua la sigueinte estructura: LLENAR DESDE A1 HASTA A23
cargar_referencia:
    LDR x10, =num               // Cargar la dirección de 'num' en el registro x10
    LDR x11, =numeroCelda_1     // Cargar la dirección de 'numeroCelda_1' en x11
    LDR x21, =num2              // Inicializar el contador de filas en 0
    MOV X15, 0                  // Inicializar el contador de columnas en 0 columna primero
    LDR x17, =numeroCelda_2     //Direccion de la segunda celda
    LDR x23, =num3              //contador de filas segundo
    LDR x24, =num4              //Aca se guardara fila del segundo parametro
    LDR x25, =num5
    LDR x26, =num6

    obtener_direccion:
        LDRB w3, [x11], 1           // Cargar el byte de 'character' en el registro w3

        CMP w3, 65              // Comparar si el carácter es la letra A
        blt error_direccion        // Si es menor que 'A', es inválido'

        CMP w3, 75              // Comparar si el carácter es la letra K
        bgt error_direccion       // Si es mayor que 'K', es inválido'

        SUB w15, w3, 65         //Como vamos a trabajar con las Columnas como letras A=65, por eso se le resta a la letra que venga
        B obtener_columna_direccion    //Continua para obtener la fila de referencia  

    error_direccion:
        print 1, errorColum, lenerrorColum
        read 0, character, 2    // Leer dos caracteres de entrada es el enter
        RET   

    obtener_columna_direccion:
        LDRB w3, [x11], 1

        CBZ w3, obtener_numero //Cuando llege al final de la palabra de direccion A12 saltar a obtener el numero

        CMP w3, 48              // Comparar si el carácter es el numero 1
        blt error_direccion        // Si es menor que '1', es un error

        CMP w3, 57              // Comparar si el numero 9
        bgt error_direccion        // Si es mayor que 9 es un error

        STRB w3, [x21], 1      //Carga el numero de fila a la variable num2 esta en texto
        B obtener_columna_direccion         // Volver a leer el siguiente carácter de las filas

    obtener_numero:
        LDR x5, =num2            // Cargar la dirección de 'num' en x5
        LDR x8, =num2            // Cargar la dirección de 'num' en x8

        STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
        BL atoi                 // Llamar a la función 'atoi' para convertir la cadena numérica
        LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila
        STR x9, [x10] //Guardamos el valor de la fila en num

        STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
        BL reset_num2       //Reiniciamos la varible num2
        LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila
        
        LDR x5, =num2 //Cargamos de nuevo el num2 ya reiniciado
        STR x15, [x5] //Guardamos el valor de la columna en num2
        MOV x15, XZR //Reiniciamos la variable del valor de columna
        B obtener_columna_objetivo




    //Aca se obtine la direccion de la segunda celda es decir el segundo parametro
    obtener_columna_objetivo:
        LDRB w3, [x17], 1

        CMP w3, 65              // Comparar si el carácter es la letra A
        blt error_columna_objetivo        // Si es menor que 'A', es un numero

        CMP w3, 75              // Comparar si el carácter es la letra K
        bgt error_columna_objetivo       // Si es mayor que 'K', es inválido' 

        SUB w15, w3, 65         //Como vamos a trabajar con las Columnas como letras A=65, por eso se le resta a la letra que venga
        B calcular_fila_objetivo         // Volver a leer el siguiente carácter de las filas


    error_columna_objetivo:
        print 1, errorGeneral, lenErrorGeneral //Imprime el error de fila o columna
        read 0, character, 2    // Leer dos caracteres de entrada
        RET
    
    calcular_fila_objetivo: 
        LDRB w3, [x17], #1   // Cargar el byte de 'character' en el registro w3, avanzar x17 en 1 byte

        CBZ w3, obtener_numero_objetivo    // Si w3 es 0 (cadena vacía), saltar a 'obtener_numero_objetivo'

        CMP w3, 48              // Valida si el el dato es numero 0
        blt error_columna_objetivo        // Compara si es menor es un error

        CMP w3, 57              // Compara si el numero es 9
        bgt error_columna_objetivo    // Si el numero es mayor es un error

        STRB w3, [x23], 1 //Carga el valor a num3
        B calcular_fila_objetivo      // Repite el ciclo hasta encontrar un valor nulo 0

    obtener_numero_objetivo:
        LDR x5, =num3            // Cargar la dirección de 'num' en x5
        LDR x8, =num3            // Cargar la dirección de 'num' en x8

        STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
        BL atoi                 // Llamar a la función 'atoi' para convertir la cadena numérica
        LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila
        STR x9, [x24]           //Guardamos el valor de la fila en num4
        
        STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
        BL reset_num3       //Reiniciamos la varible num3
        LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila
        
        LDR x5, =num3 //Cargamos de nuevo el num3 ya reiniciado
        STR x15, [x5] //Guardamos el valor de la columna en num3
        B mostrar_celdas

    
    //________En esta parte se mostrar el mensaje con la celda:______ LLENAR DESDE (primer parametro) HASTA (segundo parametro)
    //Primer parametro: num2 = columna inicio, num = fila inicio
    //Segundo parametro: num3 = columna fin, num4 = fila fin
    mostrar_celdas:
        LDR x0, =num2 //cargamos el primer numero
        LDR x0, [x0]//cargamos el valor
        LDR x1, =num //cargamos el segundo numero
        LDR x1, [x1]//cargamos el valor
        LDR x2, =num3 //cargamos el tercer numero
        LDR x2, [x2]//cargamos el valor
        LDR x3, =num4 //cargamos el cuarto numero
        LDR x3, [x3]//cargamos el valor

        CMP w1, 23 //Comparamos la fila inicio con 23
        BGT error_fila //Si fila inicio > 23

        CMP w3, 23 //Comparamos la fila final con 23
        BGT error_fila //Si fila fianl > 23
        B comprovaciones // Si no se cimple na da de lo anterior Saltamos a ingresar datos

        error_fila:
            print 1, errorFila, lenerrorFila //Este error se muestra cuando la fial es mayor a 23
            read 0, character, 2    // Leer dos caracteres de entrada
            RET                     // Retornar del procedimiento

        comprovaciones:
            CMP w0, w2 //Comparamos columna inicial con columna final
            BEQ inicio_loop1 //Si son de la misma columna 

            CMP w0, w2 //Comparamos columna inicial con columna final
            BLT inicio_loop2 //Si columna inicial < columna final

        error_columna:
            print 1, errorCol, lenerrorCol //Este error se muestra cuando la columna inicial es mayor a la final
            read 0, character, 2    // Leer dos caracteres de entrada
            RET                     // Retornar del procedimiento

        // Aca se validan unicamente cuando es en la misma columna  es decir:******** A1 HASTA A23 ***************
        inicio_loop1:
            MOV x10, 0 // Aca se guardara el valor sumado

            MOV x16, x0      // Obtener el valor de la columna
            MOV x21, x1 //Cargamos el valor de la fila
            SUB x21, x21, 1 //Obtenemos el valor correcto de las filas

            LDR x20, =arreglo       // Cargar la dirección del arreglo donde se almacenan los datos
            MOV x22, 12              // Multiplicar la fila actual por 12 (supuesto tamaño de las filas)
            MUL x22, x21, x22       // Realizar la multiplicación para calcular el offset
            ADD x22, x16, x22       // Sumar el valor de la columna al offset
            LDR x9, [x20, x22, LSL #3] // Almacenar el valor en el arreglo, ajustando el offset según el tamaño

            MOV x10, x9
            ADD x1, x1, 1   //Agregamos uno a la fila inicial
            CMP w1, w3      //Comparamos fila inicial con fila final
            BGT rd_end2     //Si fila inicial > fila final    finalizamos el programa

            loop_imprimir1:
                
                MOV x16, x0      // Obtener el valor de la columna
                MOV x21, x1 //Cargamos el valor de la fila
                SUB x21, x21, 1 //Obtenemos el valor correcto de las filas

                LDR x20, =arreglo       // Cargar la dirección del arreglo donde se almacenan los datos
                MOV x22, 12              // Multiplicar la fila actual por 12 (supuesto tamaño de las filas)
                MUL x22, x21, x22       // Realizar la multiplicación para calcular el offset
                ADD x22, x16, x22       // Sumar el valor de la columna al offset
                LDR x9, [x20, x22, LSL #3] // Almacenar el valor en el arreglo, ajustando el offset según el tamaño
                
                CMP w10, w9
                BGE IF        // Si valor anterior >= valor actual saltar 
                B esle
                
                IF: 
                    MOV x10, x9 //actualizamos el valor
                esle:
                ADD x1, x1, 1   //Agregamos uno a la fila inicial
                CMP w1, w3      //Comparamos fila inicial con fila final
                BGT rd_end2     //Si fila inicial > fila final    finalizamos el programa
                B loop_imprimir1 //Continuamos en la sigueinte iteracion



        // Aca se validan unicamente cuando es en la misma fila
        inicio_loop2:
            MOV x10, 0 // Aca se guardara el valor sumado

            MOV x16, x0      // Obtener el valor de la columna
            MOV x21, x1 //Cargamos el valor de la fila
            SUB x21, x21, 1 //Obtenemos el valor correcto de las filas

            LDR x20, =arreglo       // Cargar la dirección del arreglo donde se almacenan los datos
            MOV x22, 12              // Multiplicar la fila actual por 12 (supuesto tamaño de las filas)
            MUL x22, x21, x22       // Realizar la multiplicación para calcular el offset
            ADD x22, x16, x22       // Sumar el valor de la columna al offset
            LDR x9, [x20, x22, LSL #3] // Almacenar el valor en el arreglo, ajustando el offset según el tamaño

            MOV x10, x9
            ADD x0, x0, 1   //Agregamos uno a la columna inicial
            CMP w0, w2      //Comparamos columna inicial con columna final
            BGT rd_end2     //Si columna inicial > columna final    finalizamos el programa

            loop_imprimir2:
                MOV x16, x0      // Obtener el valor de la columna
                MOV x21, x1 //Cargamos el valor de la fila
                SUB x21, x21, 1 //Obtenemos el valor correcto de las filas

                LDR x20, =arreglo       // Cargar la dirección del arreglo donde se almacenan los datos
                MOV x22, 12              // Multiplicar la fila actual por 12 (supuesto tamaño de las filas)
                MUL x22, x21, x22       // Realizar la multiplicación para calcular el offset
                ADD x22, x16, x22       // Sumar el valor de la columna al offset
                LDR x9, [x20, x22, LSL #3] // Almacenar el valor en el arreglo, ajustando el offset según el tamaño
                
                CMP w10, w9
                BGE IF2        // Si valor anterior >= valor actual saltar 
                B esle2
                
                IF2: 
                    MOV x10, x9 //actualizamos el valor
                esle2:
                ADD x0, x0, 1   //Agregamos uno a la columna inicial
                CMP w0, w2      //Comparamos columna inicial con columna final
                BGT rd_end2     //Si columna inicial > columna final    finalizamos el programa
                B loop_imprimir2 //Continuamos en la sigueinte iteracion




    rd_end2:
        LDR x5, =retorno //Carga la direccion de la varible de retorno
        STR x10, [x5] //Se carga el valor numerico a la variable de retorno

        print 1, salto, lenSalto // Imprimir un salto de línea
        print 1, readSuccess, lenReadSuccess // Imprimir el mensaje de éxito en la lectura
        read 0, character, 2    // Leer dos caracteres de entrada
        RET                     // Retornar del procedimiento






//******************************Aca se encuentra el area de conversio de entero a text y texto a entero */
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








reset_valor:
    // Reiniciar 'num2' (10 bytes)
    LDR x0, =valor               // Dirección base de 'valor'
    MOV x1, #10                // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila
    RET



reset_num2:
    // Reiniciar 'num2' (10 bytes)
    LDR x0, =num2               // Dirección base de 'num'
    MOV x1, #10                // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila
    RET


reset_num3:
    // Reiniciar 'num3' (10 bytes)
    LDR x0, =num3               // Dirección base de 'num'
    MOV x1, #10                // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila
    RET


reset_num4:
    // Reiniciar 'num' (10 bytes)
    LDR x0, =num4               // Dirección base de 'num'
    MOV x1, #10                // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila
    RET


reset_num5:
    // Reiniciar 'num' (10 bytes)
    LDR x0, =num5               // Dirección base de 'num'
    MOV x1, #10                // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila
    RET



reset_variables:
    // Reiniciar 'num' (10 bytes)
    LDR x0, =num               // Dirección base de 'num'
    MOV x1, #10                // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

    // Reiniciar 'numeroCelda_1' (100 bytes)
    LDR x0, =numeroCelda_1      // Dirección base de 'numeroCelda_1'
    MOV x1, #100               // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

    // Reiniciar 'numeroCelda_2' (100 bytes)
    LDR x0, =numeroCelda_2 // Dirección base de 'numeroCelda_2'
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

    // Reiniciar 'num3' (10 bytes)
    LDR x0, =num3              // Dirección base de 'num3'
    MOV x1, #10                // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

    // Reiniciar 'num4' (10 bytes)
    LDR x0, =num4              // Dirección base de 'num4'
    MOV x1, #10                // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

    // Reiniciar 'num5' (10 bytes)
    LDR x0, =num5              // Dirección base de 'num5'
    MOV x1, #10                // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

    // Reiniciar 'num6' (10 bytes)
    LDR x0, =num6              // Dirección base de 'num6'
    MOV x1, #10                // Tamaño en bytes

    STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
    BL clear_memory            // Llamada a la función para establecer a cero
    LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

    // Reiniciar 'num6' (10 bytes)
    LDR x0, =valor              // Dirección base de 'valor'
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






