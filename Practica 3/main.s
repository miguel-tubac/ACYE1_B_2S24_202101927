.global _start

.section .data
    message1: .asciz "\nUniversidad de San Carlos de Guatemala\nFacultad de Ingenieria\nEscuela de Ciencias y Sistemas\nArquitectura de Computadores y Ensambladores 1\nSeccion B\nMiguel Adrian Tubac Agustin\n202101927\n\nPresione Enter para continuar...\n"
    menu: .asciz "\nMenu:\n1. Suma\n2. Resta\n3. Multiplicacion\n4. Division\n5. Calculo con memoria\n6. Finalizar calculadora\n"
    newline: .asciz "\n"
    prompt: .asciz "\nIngrese una Opción: "
    opciones: .asciz "\n1. Números separados\n2. Operación completa\n3. Separado por comas"
    opcion1: .asciz "\nIngrese el primer número:"
    opcion2: .asciz "\nIngrese el segundo número:"
    opcion3: .asciz "\nIngrese la operación completa:"
    opcion4: .asciz "\nIngrese los números separados por comas:"

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

    // Mostrar el menú
    mov x0, 1               // File descriptor para stdout
    ldr x1, =menu           // Dirección del menú
    mov x2, #100            // Longitud del menú
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
    mov x2, #1              // Leer 1 byte (la opción)
    mov x8, #63             // syscall read
    svc 0

    // Finalizar el programa
    mov x8, #93             // syscall exit
    mov x0, #0              // Código de salida 0
    svc 0


    .type suma, %function
    .global suma
suma: // an example function named myfunc

    // The function code goes here

    .size suma,(. - suma)
