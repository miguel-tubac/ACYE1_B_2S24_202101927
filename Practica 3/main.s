.global _start
.extern do_sum  // Declaramos la función externa que está en sum.S
//.extern print_number

.section .data
    message1: .asciz "\nUniversidad de San Carlos de Guatemala\nFacultad de Ingenieria\nEscuela de Ciencias y Sistemas\nArquitectura de Computadores y Ensambladores 1\nSeccion B\nMiguel Adrian Tubac Agustin\n202101927\n\nPresione Enter para continuar...\n"
    menu: .asciz "\nMenu:\n1. Suma\n2. Resta\n3. Multiplicacion\n4. Division\n5. Calculo con memoria\n6. Finalizar calculadora\n"
    newline: .asciz "\n"
    prompt: .asciz "\nIngrese una Opción: "
    invalid_option: .asciz "\nOpción no válida, intenta de nuevo...\n"
    option1: .asciz "1"
    option6: .asciz "6"

.section .bss
    .lcomm buffer, 256  // Buffer para la entrada del usuario

.section .text
_start:
    // Mostrar el mensaje de bienvenida
    mov x0, 1               // File descriptor para stdout
    ldr x1, =message1       // Dirección del mensaje
    mov x2, #222            // Longitud del mensaje
    mov x8, #64             // syscall write
    svc 0

    // Esperar a que el usuario presione Enter
    mov x0, 0               // File descriptor para stdin
    ldr x1, =buffer         // Dirección del buffer
    mov x2, #1              // Leer 1 byte (Enter)
    mov x8, #63             // syscall read
    svc 0

menu_loop:
    // Mostrar el menú
    mov x0, 1               // File descriptor para stdout
    ldr x1, =menu           // Dirección del menú
    mov x2, #102            // Longitud del menú
    mov x8, #64             // syscall write
    svc 0

    // Mostrar prompt para opción
    mov x0, 1               // File descriptor para stdout
    ldr x1, =prompt         // Dirección del prompt
    mov x2, #22              // Longitud del prompt
    mov x8, #64             // syscall write
    svc 0

    // Leer la opción seleccionada
    mov x0, 0               // File descriptor para stdin
    ldr x1, =buffer         // Dirección del buffer
    mov x2, #4              // Leer 1 byte (la opción)
    mov x8, #63             // syscall read
    svc 0

    // Comparar la opción ingresada con '6'
    ldrb w0, [x1]           // Cargar el valor de la opción (byte)
    cmp w0, #'6'            // Comparar con '6'
    beq exit_program        // Si es '6', salir del ciclo y terminar

    // Comparar la opción con '1' para la suma
    cmp w0, #'1'            // Comparar con '1'
    beq call_sum            // Si es '1', llamar a la función de suma

    // Validar si es una opción válida entre '1' y '5'
    cmp w0, #'1'            // Comparar con '1'
    blt invalid_choice      // Si es menor que '1', opción inválida
    cmp w0, #'6'            // Comparar con '6'
    bgt invalid_choice      // Si es mayor que '6', opción inválida
    
    // Si es una opción válida, repetir el ciclo
    b menu_loop


invalid_choice:
    // Mostrar prompt para opción
    mov x0, 1               // File descriptor para stdout
    ldr x1, =invalid_option         // Dirección del prompt
    mov x2, #41              // Longitud del prompt
    mov x8, #64             // syscall write
    svc 0

    // Volver al ciclo del menú
    b menu_loop

call_sum:
    bl do_sum               // Llamar a la función do_sum (en sum.S)
    //bl print_number          // Llamar a la función para imprimir el número
    b menu_loop             // Volver al menú


exit_program:

    // Finalizar el programa
    mov x8, #93             // syscall exit
    mov x0, #0              // Código de salida 0
    svc 0
