.global do_div

.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear

    menuPrincipal:
        .asciz "//// Menu Divición ////\n"
        .asciz "1. Números separados\n"
        .asciz "2. Separado por comas\n"
        .asciz "3. Regresar..\n"
        lenMenuPrincipal = .- menuPrincipal

    msgOpcion:
        .asciz "\nIngrese Una Opcion: "
        lenOpcion = .- msgOpcion

    sumaSepa:
        .asciz "...Ingresando números separados...\n"
        lenSumaText = . - sumaSepa

    denominador:
        .asciz "\n...Error no se puede dividir entre 0 ..."
        lenDeno = . - denominador

    sumaComas:
        .asciz "...Ingresando separado por comas...\n"
        lenMultiplicacionText = . - sumaComas

    opcion1: 
        .asciz "\nIngrese el primer número: "
        lenOpcion1 = .- opcion1

    opcion2: 
        .asciz "Ingrese el segundo número: "
        lenOpcion2 = .- opcion2

    result_msg: 
        .asciz "\nResultado de la divición: "
        lenResult = .- result_msg

    input1:
        .space 10
    input2:
        .space 10
    result:
        .space 12
    newline:
        .ascii "\n"
    opracionCom:
        .space 50

    erronea:
        .asciz "\nOpción no válida, intenta de nuevo..."
        lenErronea = . - erronea

    sumaPorComas:
        .asciz "\nIngrese los numeros separados por una coma: "
        lenSumaPorComas = . - sumaPorComas

    precionarEnter:
        .asciz "\n\nPresione Enter para continuar..."
        lenPrecionarEnter = . - precionarEnter

    regresandoInicio:
        .asciz "\n...Presione Enter para regresar..."
        lenRegresandoInicio = . - regresandoInicio

.bss
    opcion:
        .space 5   // => El 5 indica cuantos BYTES se reservaran para la variable opcion

.macro print texto, cantidad
    MOV x0, 1
    LDR x1, =\texto
    LDR x2, =\cantidad
    MOV x8, 64
    SVC 0 
.endm

.macro input
    MOV x0, 0
    LDR x1, =opcion
    LDR x2, =5
    MOV x8, 63
    SVC 0
.endm


.text
do_div:
    stp x29, x30, [sp, #-16]!    // Guardar el frame pointer y link register
    mov x29, sp                  // Establecer el frame pointer
    menuS:
        print clear, lenClear
        print menuPrincipal, lenMenuPrincipal
        print msgOpcion, lenOpcion
        input

        LDR x10, =opcion
        LDRB w10, [x10]

        /*// Imprimir el segundo mensaje
        mov x0, 1          // Descriptor de archivo para stdout
        ldr x1, =opcion   // Dirección del mensaje
        mov x2, #5        // Longitud del mensaje
        mov x8, 64         // Número de llamada al sistema para write
        svc 0              // Llamada al sistema*/

        cmp w10, 49
        beq divOperadoresSeparados

        cmp w10, 50
        beq divOperaComas

        cmp w10, 51
        beq end

        b invalido

        invalido:
            print erronea, lenErronea
            b cont

        divOperadoresSeparados:
            print sumaSepa, lenSumaText
            // Pedir numeros de entrada
            // replicar el funcionamiendo de atoi(ASCII TO INTEGER)[Funcion de C]
            // realizar operacion
            // replicar el funcionamiento de itoa(INTEGER TO ASCII)[Funcion de C]
            beq opcion_separados               // Llamar a la función do_sum (en sum.S)
            b cont

        divOperaComas:
            print sumaComas, lenMultiplicacionText
            beq operacion_completa
            b cont

        cont:
            input
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

    error_denominador:
        print denominador, lenDeno
        b cont


    opcion_separados:
        // Imprimir el primer mensaje
        mov x0, 1          // Descriptor de archivo para stdout
        ldr x1, =opcion1   // Dirección del mensaje
        mov x2, lenOpcion1        // Longitud del mensaje
        mov x8, 64         // Número de llamada al sistema para write
        svc 0              // Llamada al sistema

        // Leer el primer número
        mov x0, 0          // Descriptor de archivo para stdin
        ldr x1, =input1    // Dirección del buffer
        mov x2, 10       // Longitud del buffer para leer más datos
        mov x8, 63         // Número de llamada al sistema para read
        svc 0              // Llamada al sistema

        // Imprimir el segundo mensaje
        mov x0, 1          // Descriptor de archivo para stdout
        ldr x1, =opcion2   // Dirección del mensaje
        mov x2, lenOpcion2        // Longitud del mensaje
        mov x8, 64         // Número de llamada al sistema para write
        svc 0              // Llamada al sistema

        // Leer el segundo número
        mov x0, 0          // Descriptor de archivo para stdin
        ldr x1, =input2    // Dirección del buffer
        mov x2, 10       // Longitud del buffer
        mov x8, 63         // Número de llamada al sistema para read
        svc 0              // Llamada al sistema

        //Comparar si el denominaro es cero:
        ldr x10, =input2
        ldrb w10, [x10]
        cmp w10, 48
        beq error_denominador

        // Convertir input1 a entero (atoi)
        ldr x0, =input1   // cargar input1
        bl atoi           // llamar a atoi
        mov w5, w0        // guardar resultado en w5

        // Convertir input2 a entero (atoi)
        ldr x0, =input2   // cargar input2
        bl atoi           // llamar a atoi
        mov w6, w0        // guardar resultado en w6

        // Sumar los dos números
        sdiv w7, w5, w6    // w7 = w5 + w6

        // Convertir resultado a cadena (itoa)
        mov w0, w7        // cargar resultado
        ldr x1, =result   // cargar dirección de resultado
        bl itoa           // llamar a itoa

        // Mostrar mensaje
        mov x0, 1         // stdout
        ldr x1, =result_msg      // cargar mensaje
        mov x2, lenResult    // tamaño mensaje
        mov x8, 64        // syscall write
        svc 0             // llamada al sistema

        // Mostrar resultado
        mov x0, 1         // stdout
        ldr x1, =result   // cargar resultado
        mov x2, 12        // tamaño resultado
        mov x8, 64        // syscall write
        svc 0             // llamada al sistema

        // Mostrar el precionar enter
        mov x0, 1              // Descriptor de archivo para stdout
        ldr x1, =precionarEnter       // Dirección de nueva línea
        mov x2, lenPrecionarEnter             // Tamaño de nueva línea
        mov x8, 64             // Número de llamada al sistema para write
        svc 0                  // Llamada al sistema
        
        // Reiniciar variables
        b reiniciar_variables



    operacion_completa:
            // Imprimir el primer mensaje
            mov x0, 1              // Descriptor de archivo para stdout
            ldr x1, =sumaPorComas  // Dirección del mensaje
            mov x2, lenSumaPorComas    // Longitud del mensaje
            mov x8, 64             // Número de llamada al sistema para write
            svc 0                  // Llamada al sistema

            // Leer la operación completa
            mov x0, 0              // Descriptor de archivo para stdin
            ldr x1, =opracionCom   // Dirección del buffer
            mov x2, 50             // Longitud del buffer
            mov x8, 63             // Número de llamada al sistema para read
            svc 0                  // Llamada al sistema

            // Procesar la cadena de operación
            ldr x0, =opracionCom   // Cargar dirección de la cadena de operación
            bl find_operator       // Encontrar el operador '+' y dividir la cadena

            // Convertir input1 a entero (atoi)
            mov x0, x5   // cargar input1
            bl atoi           // llamar a atoi
            mov w5, w0        // guardar resultado en w5

            //Comparar si el denominaro es cero:
            ldrb w10, [x6]
            cmp w10, 48
            beq error_denominador

            // Convertir input2 a entero (atoi)
            mov x0, x6   // cargar input2
            bl atoi           // llamar a atoi
            mov w6, w0        // guardar resultado en w6

            // Sumar los dos números
            sdiv w7, w5, w6         // w7 = w5 + w6

            // Convertir resultado a cadena (itoa)
            mov w0, w7             // Cargar resultado
            ldr x1, =result        // Cargar dirección de resultado
            bl itoa                // Llamar a itoa

            // Mostrar mensaje
            mov x0, 1              // Descriptor de archivo para stdout
            ldr x1, =result_msg    // Dirección del mensaje
            mov x2, lenResult      // Tamaño del mensaje
            mov x8, 64             // Número de llamada al sistema para write
            svc 0                  // Llamada al sistema

            // Mostrar resultado
            mov x0, 1              // Descriptor de archivo para stdout
            ldr x1, =result        // Dirección del resultado
            mov x2, 12             // Tamaño del resultado
            mov x8, 64             // Número de llamada al sistema para write
            svc 0                  // Llamada al sistema

            // Mostrar el precionar enter
            mov x0, 1              // Descriptor de archivo para stdout
            ldr x1, =precionarEnter       // Dirección de nueva línea
            mov x2, lenPrecionarEnter             // Tamaño de nueva línea
            mov x8, 64             // Número de llamada al sistema para write
            svc 0                  // Llamada al sistema

            // Reiniciar variables
            b reiniciar_variables

    // Función para encontrar el operador '+' y dividir la cadena
    find_operator:
        ldr x2, =opracionCom     // Cargar dirección de la cadena de operación
        mov x3, x2               // Guardar la dirección inicial para procesar el primer número

        find_loop:
            ldrb w4, [x2]            // Cargar un carácter de la cadena
            cmp w4, ','              // Comparar con el operador '+'
            beq found_plus           // Si es '+', proceder

            add x2, x2, 1            // Mover al siguiente carácter
            cbnz w4, find_loop       // Repetir hasta encontrar '+'

        found_plus:
            strb wzr, [x2]           // Colocar un terminador nulo después del '+'

            // Convertir el primer número de la cadena a entero (input1)
            mov x0, x3               // Dirección del inicio de la cadena
            mov w5, w0               // Guardar el primer número en w5 (input1)

            // Procesar el segundo número después del '+'
            add x0, x2, 1            // Apuntar justo después del '+'
            mov w6, w0               // Guardar el segundo número en w6 (input2)

        ret







    // Función itoa: convierte entero a cadena con la validacion de los negativos
    itoa:
        cmp w0, #0           // Comparar el número con 0
        bge itoa_positive     // Si es mayor o igual a 0, continuar con la conversión normal
        
        // Manejar número negativo
        neg w0, w0            // Convertir el número a positivo
        mov w3, '-'           // Colocar el signo negativo
        
        strb w3, [x1]        // Almacenar el signo negativo
        add x1, x1, 1        // Mover puntero para la siguiente posición

        //sub x1, x1, 1         // Retroceder puntero
        //strb w3, [x1]         // Almacenar el signo negativo

        itoa_positive:
            mov w2, 10            // Base 10
            add x1, x1, 11        // Mover puntero al final
            strb wzr, [x1]        // Agregar terminador nulo

        itoa_loop:
            udiv w3, w0, w2       // Dividir número por 10
            msub w4, w3, w2, w0   // Obtener residuo
            add w4, w4, '0'       // Convertir residuo a carácter
            sub x1, x1, 1         // Retroceder puntero
            strb w4, [x1]         // Almacenar carácter
            mov w0, w3            // Actualizar número
            cbnz w0, itoa_loop    // Repetir mientras no sea 0
            ret                   // Retornar


    // Función para convertir una cadena ASCII a entero con la validacion de signos
    atoi:
        mov w1, 0          // Inicializar el resultado
        mov w2, 0          // Inicializar signo (0 = positivo, 1 = negativo)

        ldrb w3, [x0], 1   // Cargar el primer carácter
        cmp w3, '-'        // Comparar con el carácter '-'
        bne check_digit    // Si no es '-', continuar con la conversión normal
        mov w2, 1          // Marcar el número como negativo
        ldrb w3, [x0], 1   // Avanzar al siguiente carácter después del signo

        check_digit:
            sub w3, w3, '0'    // Convertir el carácter a número
            cmp w3, 9          // Verificar si es un número válido (0-9)
            bhi atoi_end       // Si no es un número, finalizar

        atoi_loop:
            mov w4, 10         // Cargar el valor 10 en w4 para multiplicar
            mul w1, w1, w4     // Multiplicar el resultado actual por 10
            add w1, w1, w3     // Sumar el dígito actual al resultado

            ldrb w3, [x0], 1   // Cargar el siguiente byte
            sub w3, w3, '0'    // Convertir carácter a número
            cmp w3, 9          // Verificar si es número válido
            bls atoi_loop      // Si es un número, repetir

        atoi_end:
            cmp w2, 1          // Comprobar si el número era negativo
            bne atoi_finish    // Si no es negativo, finalizar
            neg w1, w1         // Si es negativo, cambiar el signo

        atoi_finish:
            mov w0, w1         // Devolver el resultado en w0
            ret                // Retornar el valor




    reiniciar_variables:
        // Limpiar input1
        ldr x0, =input1
        mov w1, #0          // Poner 0 (nulo)
        mov w2, #10         // Limitar a 10 bytes
        reset_input1:
            strb w1, [x0], #1   // Escribir 0 en cada byte del buffer
            subs w2, w2, #1
            b.ne reset_input1   // Si aún no hemos escrito en todos los bytes, repetir

            // Limpiar input2
            ldr x0, =input2
            mov w2, #10
        reset_input2:
            strb w1, [x0], #1
            subs w2, w2, #1
            b.ne reset_input2

            // Limpiar result
            ldr x0, =result
            mov w2, #12
        reset_result:
            strb w1, [x0], #1
            subs w2, w2, #1
            b.ne reset_result

            // Limpiar opcion (aunque no es necesario aquí, lo hago por consistencia)
            ldr x0, =opcion
            mov w2, #5
        reset_opcion:
            strb w1, [x0], #1
            subs w2, w2, #1
            b.ne reset_opcion

            b cont





