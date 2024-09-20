.global do_memoria

.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear

    menuPrincipal:
        .asciz "_____ Menu Calculo Con Memoria ____\n"
        .asciz "1. Iniciar calculo\n"
        .asciz "2. Regresar..\n"
        lenMenuPrincipal = .- menuPrincipal

    msgOpcion:
        .asciz "\nIngrese Una Opcion: "
        lenOpcion = .- msgOpcion

    sumaSepa:
        .asciz "...Ingresando al calculo con memoria...\n"
        lenSumaText = . - sumaSepa

    operacionComple:
        .asciz "\nIngrese la operacion completa: "
        lenOperacionComple = . - operacionComple

    opcion1: 
        .asciz "Estamos en input1"
        lenOpcion1 = .- opcion1

    opcion22: 
        .asciz "Estamos en recuperar anterior"
        lenOpcion22 = .- opcion22

    result_msg: 
        .asciz "\nResultado: "
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
    acumulado:
        .space 12
    primera_ejecucion: 
        .space 10 // Inicialmente, es la primera ejecución
    operador:
        .space 10

    erronea:
        .asciz "\nOpción no válida, intenta de nuevo..."
        lenErronea = . - erronea

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
do_memoria:
    //
    /*// Inicializar acumulado a 0 al principio del programa
    mov x2, #0               // Mueve 0 a x2
    ldr x1, =acumulado        // Carga la dirección de 'acumulado'
    str x2, [x1]             // Guarda 0 en 'acumulado'*/

    mov x2, #1               // Mueve 0 a x2
    ldr x1, =primera_ejecucion        // Carga la dirección de 'acumulado'
    str x2, [x1]             // Guarda 0 en 'acumulado'*/

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
        beq incioConCalculoMemoria

        cmp w10, 50
        beq end

        b invalido

        invalido:
            print erronea, lenErronea
            b cont

        incioConCalculoMemoria:
            print sumaSepa, lenSumaText
            // Pedir numeros de entrada
            // replicar el funcionamiendo de atoi(ASCII TO INTEGER)[Funcion de C]
            // realizar operacion
            // replicar el funcionamiento de itoa(INTEGER TO ASCII)[Funcion de C]
            beq operacion_completa               // Llamar a la función 
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



    operacion_completa:
        // Imprimir el primer mensaje
        mov x0, 1              // Descriptor de archivo para stdout
        ldr x1, =operacionComple  // Dirección del mensaje
        mov x2, lenOperacionComple    // Longitud del mensaje
        mov x8, 64             // Número de llamada al sistema para write
        svc 0                  // Llamada al sistema

        leer_operacion:
            // Inicializar acumulado a 0 al principio del programa
            mov x5, #0
            mov x6, #0              

            // Leer la operación completa
            mov x0, 0              // Descriptor de archivo para stdin
            ldr x1, =opracionCom   // Dirección del buffer
            mov x2, 50             // Longitud del buffer
            mov x8, 63             // Número de llamada al sistema para read
            svc 0                  // Llamada al sistema

            // Procesar la cadena de operación
            ldr x0, =opracionCom   // Cargar dirección de la cadena de operación
            bl find_operator       // Encontrar el operador '+' y dividir la cadena

            /*// Imprimir dirección del puntero x2
            mov x0, 1              // Descriptor de archivo para stdout
            mov x1, x4             // Dirección de la cadena actual
            mov x2, 10             // Tamaño del mensaje (ajusta según el tamaño)
            mov x8, 64             // syscall: write
            svc 0       //*/

        suma_separada:
            ldr x1, =primera_ejecucion // Cargar la dirección de primera_ejecucion
            ldr w2, [x1]                // Cargar el valor de primera_ejecucion

            // Verificar si es la primera ejecución
            cbz w2, obtener_anterior    // Si es 0, ir a obtener_anterior

            // Caso cuando se ingresa solo un nuevo valor como "+3"
            // Input1 es el valor acumulado
            b convertir_input1
        
        obtener_anterior:
            ldr x10, =acumulado          // Cargar la dirección de 'acumulado'
            ldr w5, [x10]                // Cargar el valor de 'acumulado'
            //print opcion22, lenOpcion22

            // Convertir input2 a entero (atoi)
            mov x0, x6   // cargar input2
            bl atoi           // llamar a atoi
            mov w6, w0        // guardar resultado en w6

            b seleccion_operacion
        
        convertir_input1:
            // Al finalizar la operación, actualizar la variable booleana
            mov x2, #0               // Mueve 0 a x2
            ldr x1, =primera_ejecucion        // Carga la dirección de 'acumulado'
            str x2, [x1]             // Guarda 0 en 'acumulado'
            //print opcion1, lenOpcion1

            // Convertir input1 a entero (atoi)
            mov x0, x5   // cargar input1
            bl atoi           // llamar a atoi
            mov w5, w0        // guardar resultado en w5*/

            // Convertir input2 a entero (atoi)
            mov x0, x6   // cargar input2
            bl atoi           // llamar a atoi
            mov w6, w0        // guardar resultado en w6

            //b seleccion_operacion
            
        seleccion_operacion:
            /*// Imprimir dirección del puntero x2
            mov x0, 1              // Descriptor de archivo para stdout
            ldr x1, =operador             // Dirección de la cadena actual
            mov x2, 10             // Tamaño del mensaje (ajusta según el tamaño)
            mov x8, 64             // syscall: write
            svc 0       //*/
            ldr x1, =operador // Cargar la dirección de primera_ejecucion
            ldr w2, [x1]                // Cargar el valor de primera_ejecucion

            cmp w2, '+'               
            beq realizar_suma 
            cmp w2, '-'               
            beq realizar_resta  
            cmp w2, '*'               
            beq realizar_multi 
            cmp w2, '/'               
            beq realizar_divi       

            b continuar    

        realizar_suma:
            add w7, w5, w6       // Realiza la suma
            b continuar           // Saltar a continuar

        realizar_resta:
            sub w7, w5, w6      
            b continuar      

        realizar_multi:
            mul w7, w5, w6      
            b continuar  
        
        realizar_divi:
            sdiv w7, w5, w6      
            b continuar  

        continuar:
            // Almacenar el nuevo resultado en acumulado
            ldr x1, =acumulado     // Cargar la dirección de "acumulado" en x1
            str w7, [x1]           // Almacenar el valor de w7 en la dirección de "acumulado"

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
            
            b reiniciar_variables2
            

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
            cmp w4, '+'              // Comparar con el operador '+'
            beq found_plus           // Si es '+', proceder
            cmp w4, '-'
            beq found_plus 
            cmp w4, '*'
            beq found_plus 
            cmp w4, '/'
            beq found_plus 
            

            add x2, x2, 1            // Mover al siguiente carácter
            cbnz w4, find_loop       // Repetir hasta encontrar '+'

        found_plus:
            ldr x1, =operador     // Cargar la dirección de "acumulado" en x1
            str w4, [x1]           // Almacenar el valor de w7 en la dirección de "acumulado"

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


    reiniciar_variables2:
        // Limpiar input1
        ldr x0, =input1
        mov w1, #0          // Poner 0 (nulo)
        mov w2, #10         // Limitar a 10 bytes
        reset_input11:
            strb w1, [x0], #1   // Escribir 0 en cada byte del buffer
            subs w2, w2, #1
            b.ne reset_input11   // Si aún no hemos escrito en todos los bytes, repetir

            // Limpiar input2
            ldr x0, =input2
            mov w2, #10
        reset_input22:
            strb w1, [x0], #1
            subs w2, w2, #1
            b.ne reset_input22

             // Limpiar result
            ldr x0, =result
            mov w2, #12
        reset_result1:
            strb w1, [x0], #1
            subs w2, w2, #1
            b.ne reset_result1

            // Limpiar opcion (aunque no es necesario aquí, lo hago por consistencia)
            ldr x0, =opcion
            mov w2, #5
        reset_opcion1:
            strb w1, [x0], #1
            subs w2, w2, #1
            b.ne reset_opcion1

        b leer_operacion



