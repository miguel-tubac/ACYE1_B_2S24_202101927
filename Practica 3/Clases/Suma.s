.global do_sum

.section .data
    opciones: .asciz "\nMenu SUMA:\n1. Números separados\n2. Operación completa\n3. Separado por comas\n4. Regresar.."
    seleccion: .asciz "\nIngrese una Opción: "
    opcion1: .asciz "\nIngrese el primer número: "
    opcion2: .asciz "Ingrese el segundo número: "
    newline: .asciz "\n"
    invalid_option: .asciz "\nOpción no válida, intenta de nuevo...\n"
    result_msg: .asciz "Resultado de la suma: "

.section .bss
    .lcomm buffer, 256  // Buffer para almacenar la entrada del usuario
    .lcomm num1, 4      // Buffer para el primer número (como entero, 4 bytes)
    .lcomm num2, 4      // Buffer para el segundo número (como entero, 4 bytes)
    .lcomm result, 10   // Buffer para el resultado de la suma (como cadena ASCII)

.section .text
do_sum:
    /*
    // Esperar a que el usuario presione Enter
    mov x0, 0               // File descriptor para stdin
    ldr x1, =buffer         // Dirección del buffer
    mov x2, #1              // Leer 1 byte (Enter)
    mov x8, #63             // syscall read
    svc 0
    */

suma_loop:
    // Imprimir el menu
    mov x0, 1          // Descriptor de archivo para stdout
    ldr x1, =opciones   // Dirección del mensaje
    mov x2, #92        // Longitud del mensaje
    mov x8, 64         // Número de llamada al sistema para write
    svc 0              // Llamada al sistema

    // Mostrar la selccion de opcion
    mov x0, 1               // File descriptor para stdout
    ldr x1, =seleccion         // Dirección del prompt
    mov x2, #22              // Longitud del prompt
    mov x8, #64             // syscall write
    svc 0

    // Leer la opción seleccionada
    mov x0, 0               // File descriptor para stdin
    mov x1, #0
    ldr x1, =buffer         // Dirección del buffer
    mov x2, #4              // Leer 1 byte (la opción)
    mov x8, #63             // syscall read
    svc 0

    // Comparar la opción ingresada con '4'
    ldrb w0, [x1]           // Cargar el valor de la opción (byte)
    cmp w0, #'4'            // Comparar con '4'
    beq salir        // Si es '4', salir del ciclo y regresar al menu principal

    // Comparar la opción con '1' para la suma
    cmp w0, #'1'            // Comparar con '1'
    beq opcion_separados            // Si es '1', llamar a la función de suma

    // Validar si es una opción válida entre '1' y '5'
    cmp w0, #'1'            // Comparar con '1'
    blt seleccion_invalida      // Si es menor que '1', opción inválida
    cmp w0, #'4'            // Comparar con '5'
    bgt seleccion_invalida      // Si es mayor que '5', opción inválida

    // Si es una opción válida, repetir el ciclo
    b suma_loop

    ret

salir: 
    ret

seleccion_invalida:
    // Mostrar prompt para opción
    mov x0, 1               // File descriptor para stdout
    ldr x1, =invalid_option         // Dirección del prompt
    mov x2, #41              // Longitud del prompt
    mov x8, #64             // syscall write
    svc 0

    // Volver al ciclo del menú
    b suma_loop

opcion_separados:
    // Imprimir el primer mensaje
    mov x0, 1          // Descriptor de archivo para stdout
    ldr x1, =opcion1   // Dirección del mensaje
    mov x2, #28        // Longitud del mensaje
    mov x8, 64         // Número de llamada al sistema para write
    svc 0              // Llamada al sistema

    // Leer el primer número
    mov x0, 0          // Descriptor de archivo para stdin
    ldr x1, =buffer    // Dirección del buffer
    mov x2, #50       // Longitud del buffer para leer más datos
    mov x8, 63         // Número de llamada al sistema para read
    svc 0              // Llamada al sistema

    // Convertir el primer número de ASCII a entero
    ldr x1, =buffer    // Dirección del buffer
    ldr x2, =num1      // Dirección para almacenar el entero
    bl ascii_to_int    // Llamar a la función para convertir ASCII a entero


    // Imprimir el segundo mensaje
    mov x0, 1          // Descriptor de archivo para stdout
    ldr x1, =opcion2   // Dirección del mensaje
    mov x2, #28        // Longitud del mensaje
    mov x8, 64         // Número de llamada al sistema para write
    svc 0              // Llamada al sistema

    // Leer el segundo número
    mov x0, 0          // Descriptor de archivo para stdin
    ldr x1, =buffer    // Dirección del buffer
    mov x2, #50       // Longitud del buffer
    mov x8, 63         // Número de llamada al sistema para read
    svc 0              // Llamada al sistema

    // Convertir el segundo número de ASCII a entero
    ldr x1, =buffer    // Dirección del buffer
    ldr x2, =num2      // Dirección para almacenar el entero
    bl ascii_to_int    // Llamar a la función para convertir ASCII a entero

    // Realizar la suma
    ldr x1, =num1      // Cargar el primer número
    ldr x2, =num2      // Cargar el segundo número
    ldr w3, [x1]       // Leer el primer número
    ldr w4, [x2]       // Leer el segundo número
    add w5, w3, w4     // Sumar los dos números
    ldr x1, =result    // Dirección para almacenar el resultado
    str w5, [x1]       // Guardar el resultado en el buffer

    // Imprimir el mensaje del resultado
    mov x0, 1          // Descriptor de archivo para stdout
    ldr x1, =result_msg // Dirección del mensaje
    mov x2, #23        // Longitud del mensaje
    mov x8, 64         // Número de llamada al sistema para write
    svc 0              // Llamada al sistema

    // Imprimir el resultado de la suma
    ldr x1, =result    // Dirección del resultado
    ldr w0, [x1]       // Cargar el resultado a convertir
    bl int_to_ascii    // Llamar a la función para convertir entero a ASCII

    mov x0, 1          // Descriptor de archivo para stdout
    ldr x2, =buffer    // Dirección del buffer con el resultado
    ldr x1, [x2]       // Longitud del resultado (aquí asumimos que es menor a 256 bytes)
    mov x8, 64         // Número de llamada al sistema para write
    svc 0              // Llamada al sistema

    // Volver al ciclo del menú
    b suma_loop



// Función para convertir una cadena ASCII a entero
ascii_to_int:
    mov w3, 0          // Inicializar el entero resultante
    ldr x4, =buffer    // Dirección de la cadena
convert_loop:
    ldrb w5, [x4], #1 // Cargar un byte de la cadena
    cmp w5, #0         // Comparar con el fin de cadena
    beq convert_done   // Si es el fin de cadena, terminar
    sub w5, w5, #'0'   // Convertir de ASCII a número
    mov w6, #10        // Cargar el valor inmediato 10 en w6
    mul w3, w3, w6     // Multiplicar el resultado actual por 10
    add w3, w3, w5     // Sumar el dígito
    b convert_loop     // Continuar con el siguiente dígito
convert_done:
    str w3, [x2]       // Almacenar el resultado
    ret

// Función para convertir un entero a cadena ASCII
int_to_ascii:
    mov w3, 10         // Base decimal
    mov x4, x0         // Valor a convertir
    ldr x2, =buffer    // Dirección del buffer
    add x2, x2, #255   // Colocar el puntero al final del buffer
    mov w1, #0         // Inicializar el índice del buffer
reverse_loop:
    udiv x0, x4, x3    // Dividir valor por 10
    mul x1, x0, x3     // Multiplicar el cociente por 10
    sub x1, x4, x1     // Obtener el dígito
    //mov x1, x1         // Mover el dígito a un registro de 32 bits (copiar parte baja de x1 a w1)
    add w1, w1, #48    // Convertir dígito a ASCII
    strb w1, [x2], #-1 // Almacenar en el buffer (usa w1 para almacenar un byte)
    mov x4, x0         // Actualizar valor
    cmp x4, #0         // Verificar si se ha terminado
    bne reverse_loop   // Si no ha terminado, continuar

    mov x0, x2         // Establecer puntero al inicio del buffer
    ret




