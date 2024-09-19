.global do_div

.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear

    menuPrincipal:
        .asciz "//// Menu Divición ////\n"
        .asciz "1. Números separados\n"
        .asciz "2. Operación completa\n"
        .asciz "3. Separado por comas\n"
        .asciz "4. Regresar..\n"
        lenMenuPrincipal = .- menuPrincipal

    msgOpcion:
        .asciz "Ingrese Una Opcion: "
        lenOpcion = .- msgOpcion

    sumaSepa:
        .asciz "Ingresando números separados\n"
        lenSumaText = . - sumaSepa

    sumaOpera:
        .asciz "Ingresando operación completa\n"
        lenRestaText = . - sumaOpera

    sumaComas:
        .asciz "Ingresando separado por comas\n"
        lenMultiplicacionText = . - sumaComas

    opcion1: 
        .asciz "\nIngrese el primer número: "
        lenOpcion1 = .- opcion1

    opcion2: 
        .asciz "Ingrese el segundo número: "
        lenOpcion2 = .- opcion2

    result_msg: 
        .asciz "Resultado de la divición: "
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
    
    completoSuma:
        .asciz "\nIngrese la operación completa: "
        lenCompleto = . - completoSuma

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
        beq multiOperadoresSeparados

        cmp w10, 50
        beq multiOperaCompleta

        cmp w10, 51
        beq multiOperaComas

        cmp w10, 52
        beq end

        b invalido

        invalido:
            print erronea, lenErronea
            b cont

        multiOperadoresSeparados:
            print sumaSepa, lenSumaText
            // Pedir numeros de entrada
            // replicar el funcionamiendo de atoi(ASCII TO INTEGER)[Funcion de C]
            // realizar operacion
            // replicar el funcionamiento de itoa(INTEGER TO ASCII)[Funcion de C]
            beq opcion_separados               // Llamar a la función do_sum (en sum.S)
            b cont

        multiOperaCompleta:
            print sumaOpera, lenRestaText
            //beq operacion_completa
            b cont

        multiOperaComas:
            print sumaComas, lenMultiplicacionText
            b cont

        cont:
            input
            b menuS

    end:
        ldp x29, x30, [sp], #16      // Restaurar el frame pointer y link register
        ret                          // Regresar al punto donde se llamó


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

        // Mostrar nueva línea
        mov x0, 1         // stdout
        ldr x1, =newline  // cargar nueva línea
        mov x2, 1         // tamaño nueva línea
        mov x8, 64        // syscall write
        svc 0             // llamada al sistema
        
        // Reiniciar variables
        b reiniciar_variables











    // Función itoa: convierte entero a cadena con la validacion de los negativos
    itoa:
        cmp w0, #0           // Comparar el número con 0
        bge itoa_positive     // Si es mayor o igual a 0, continuar con la conversión normal
        
        // Manejar número negativo
        neg w0, w0            // Convertir el número a positivo
        mov w3, '-'           // Colocar el signo negativo
        sub x1, x1, 1         // Retroceder puntero
        strb w3, [x1]         // Almacenar el signo negativo

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





