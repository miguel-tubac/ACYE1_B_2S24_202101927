.extern do_tabla


.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear
    
    encabezado:
        .asciz "Universidad De San Carlos De Guatemala\n"
        .asciz "Facultad De Ingenieria\n"
        .asciz "Escuela de Ciencias y Sistemas\n"
        .asciz "Arquitectura de Computadores y Ensambladores 1\n"
        .asciz "Seccion B\n"
        .asciz "Miguel Adrian Tubac Agustin\n"
        .asciz "202101927\n"
        .asciz "\n"
        .asciz "Presione Enter para continuar..."
        lenEncabezado = . - encabezado
    
    menuPrincipal:
        .asciz ">>>> Menu Principal <<<<\n"
        .asciz "1. Iniciar la Tabla\n"
        .asciz "2. Finalizar programa...\n"
        lenMenuPrincipal = .- menuPrincipal
    
    msgOpcion:
        .asciz "\nIngrese Una Opcion: "
        lenOpcion = .- msgOpcion
    
    erronea:
        .asciz "\nOpción no válida, intenta de nuevo..."
        lenErronea = . - erronea

    msgSalida:
        .asciz "\n                                     ...¡¡¡¡Que tenga un feliz día!!!!..."
        lenMsgSalida = . - msgSalida

    newline:
        .asciz "\n"
        lennewline = . - newline
    
    opcionSalir:
        .asciz "1. Salir\n"
        .asciz "2. Regresar\n"
        lenOpcionSalir = .- opcionSalir


.bss
    opcion:
        .space 5   // => El 5 indica cuantos BYTES se reservaran para la variable opcion
    



.text
// Macro para imprimir strings
.macro print reg, len
    MOV x0, 1
    LDR x1, =\reg
    MOV x2, \len
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


_start:
    print clear, lenClear
    print encabezado, lenEncabezado
    input

    menu: 
        print clear, lenClear
        print menuPrincipal, lenMenuPrincipal
        print msgOpcion, lenOpcion
        input

        LDR x10, =opcion
        LDRB w10, [x10]

        cmp w10, 49
        beq inciar_tabla

        cmp w10, 50
        beq salida

        b invalido

        invalido:
            print erronea, lenErronea
            B cont

        inciar_tabla:
            bl do_tabla
            B cont

        cont:
            input
            B menu

    end:
        print msgSalida, lenMsgSalida 

        input

        // Mostrar el precionar enter
        mov x0, 1              // Descriptor de archivo para stdout
        ldr x1, =newline      // Dirección de nueva línea
        mov x2, 1            // Tamaño de nueva línea
        mov x8, 64             // Número de llamada al sistema para write
        svc 0                  // Llamada al sistema

        MOV x0, 0   // Codigo de error de la aplicacion -> 0: no hay error
        MOV x8, 93  // Codigo de la llamada al sistema
        SVC 0       // Ejecutar la llamada al sistema



    salida:
        print clear, lenClear
        // Mostrar el precionar enter
        mov x0, 1              // Descriptor de archivo para stdout
        ldr x1, =newline      // Dirección de nueva línea
        mov x2, 1            // Tamaño de nueva línea
        mov x8, 64             // Número de llamada al sistema para write
        svc 0                  // Llamada al sistema
        
        print opcionSalir, lenOpcionSalir
        print msgOpcion, lenOpcion
        input
        
        LDR x10, =opcion
        LDRB w10, [x10]

        cmp w10, 49
        beq end

        cmp w10, 50
        beq menu

        b salida
















