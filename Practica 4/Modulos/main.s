.global _start
.extern do_numeros
// Declarar las variables como externas
.extern do_bubble
.extern do_quick
.extern do_InsertionSort
.extern do_mergeSort

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
        .asciz "1. Ingreso de lista de números\n"
        .asciz "2. Bubble Sort\n"
        .asciz "3. Quick Sort\n"
        .asciz "4. Insertion Sort\n"
        .asciz "5. Merge Sort\n"
        .asciz "6. Reiniciar el contenido del Reporte...\n"
        .asciz "7. Finalizar programa...\n"
        lenMenuPrincipal = .- menuPrincipal

    msgOpcion:
        .asciz "\nIngrese Una Opcion: "
        lenOpcion = .- msgOpcion

    sumaText:
        .asciz "Ingresando Lista de números\n"
        lenSumaText = . - sumaText

    restaText:
        .asciz "Ingresando Bubble Sort\n"
        lenRestaText = . - restaText

    multiplicacionText:
        .asciz "Ingresando Quick Sort\n"
        lenMultiplicacionText = . - multiplicacionText

    divisionText:
        .asciz "Ingresando Insertion Sort\n"
        lenDivisionText = . - divisionText

    operacionesText:
        .asciz "Ingresando Merge Sort\n"
        lenOperacionesText = . - operacionesText

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

    filename2:    
        .asciz "salida.txt"     // Nombre del archivo

    errorOpenFile:
        .asciz "Error al abrir el archivo\n"
        lenErrOpenFile = .- errorOpenFile

    recet:
        .asciz "\n\n !!Archivo vaciado correctamente¡¡¡"
        lenrecet = . - recet

    encabezado2:
        .ascii "Universidad De San Carlos De Guatemala\n"
        .ascii "Facultad De Ingenieria\n"
        .ascii "Escuela de Ciencias y Sistemas\n"
        .ascii "Arquitectura de Computadores y Ensambladores 1\n"
        .ascii "Seccion B\n"
        .ascii "Miguel Adrian Tubac Agustin\n"
        .ascii "202101927\n"
        .ascii "\n"
        lenEncabezado2 = . - encabezado2



.bss
    opcion:
        .space 5   // => El 5 indica cuantos BYTES se reservaran para la variable opcion

    fileDescriptor:
        .space 8


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

.macro agregarTexto stdout, reg, len
    MOV x0, \stdout
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm


.text
_start:
    // Colocar el codigo ARM
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
        beq lista_numeros

        cmp w10, 50
        beq Bubble_Sort

        cmp w10, 51
        beq Quick_Sort

        cmp w10, 52
        beq Insertion_Sort

        cmp w10, 53
        beq Merge_Sort

        cmp w10, 54
        beq reiniciarReporte

        cmp w10, 55
        beq salida

        b invalido

        invalido:
            print erronea, lenErronea
            B cont

        lista_numeros:
            print sumaText, lenSumaText
            // Pedir numeros de entrada
            // replicar el funcionamiendo de atoi(ASCII TO INTEGER)[Funcion de C]
            // realizar operacion
            // replicar el funcionamiento de itoa(INTEGER TO ASCII)[Funcion de C]
            bl do_numeros               // Llamar a la función do_sum (en sum.S)
            B cont

        Bubble_Sort:
            print restaText, lenRestaText
            // Llamar Algoritmo de Ordenamiento Burbuja
            bl do_bubble
            
            b cont

        Quick_Sort:
            print multiplicacionText, lenMultiplicacionText
            bl do_quick
            B cont

        Insertion_Sort:
            print divisionText, lenDivisionText
            bl do_InsertionSort
            B cont
        
        Merge_Sort:
            print operacionesText, lenOperacionesText
            bl do_mergeSort
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



reiniciarReporte:
    stp x29, x30, [sp, #-16]!    // Guardar el frame pointer y link register
    bl vaciarArchivo

    LDR x20, =fileDescriptor     // Cargar la dirección de fileDescriptor
    LDR x20, [x20]               // Cargar el descriptor del archivo en x20

    agregarTexto x20, encabezado2, lenEncabezado2

    bl closeFile
    ldp x29, x30, [sp], #16      // Restaurar el frame pointer y link register
    B cont
    
    //ret


vaciarArchivo:
    MOV x0, -100                 // openat con AT_FDCWD (directorio actual)
    LDR x1, =filename2           // Dirección del nombre del archivo
    MOV x2, 577                  // O_WRONLY | O_TRUNC (para truncar el archivo)
    MOV x3, 0666                 // Permisos de lectura y escritura
    MOV x8, 56                   // Syscall número 56 (openat)
    SVC #0                       // Llamada al sistema

    CMP x0, 0
    BLT vac_error                // Si x0 es negativo, es un error
    LDR x9, =fileDescriptor      // Dirección para almacenar el file descriptor
    STR x0, [x9]                 // Guardar el file descriptor
    B vac_end

    vac_error:
        print errorOpenFile, lenErrOpenFile
        RET

    vac_end:
        print recet, lenrecet
        RET



closeFile:
    LDR x0, =fileDescriptor
    LDR x0, [x0]
    MOV x8, 57
    SVC 0
    RET  



