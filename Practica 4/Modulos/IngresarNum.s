.global do_numeros
.global openFile
.global closeFile
.global readCSV
.global atoi
.global itoa

.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear

    menuPrincipal:
        .asciz "------ Menu Lista de Números ------\n"
        .asciz "1. De forma manual\n"
        .asciz "2. Carga de Archivo csv\n"
        .asciz "3. Regresar..\n"
        lenMenuPrincipal = .- menuPrincipal

    msgOpcion:
        .asciz "\nIngrese Una Opcion: "
        lenOpcion = .- msgOpcion

    sumaComas:
        .asciz "...Ingresando separado por comas...\n"
        lenMultiplicacionText = . - sumaComas

    cargacsv:
        .asciz "...Ingresando a la carga de archivo CSV...\n"
        lencargacsv = . - cargacsv

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
    
    errorOpenFile:
        .asciz "Error al abrir el archivo\n"
        lenErrOpenFile = .- errorOpenFile
    
    salto:
        .asciz "\n"
        lenSalto = .- salto

    readSuccess:
        .asciz "El Archivo Se Ha Leido Correctamente\n"
        lenReadSuccess = .- readSuccess
    
    msgFilename:
        .asciz "Ingrese el nombre del archivo: "
        lenMsgFilename = .- msgFilename


.bss
    .global array   // Agregar esta línea
    .global count   // Agregar esta línea
    //.global num

    opcion:
        .space 5   // => El 5 indica cuantos BYTES se reservaran para la variable opcion

    fileDescriptor:
        .space 8

    num:
        .space 4
    
    array:
        .skip 1024

    character:
        .byte 0

    count:
        .zero 8

    filename:
        .zero 50


// Macro para imprimir strings
.macro print reg, len
    MOV x0, 1
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

// Macro para leer datos del usuario
.macro read stdin, buffer, len
    MOV x0, \stdin
    LDR x1, =\buffer
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm


.text
do_numeros:
    stp x29, x30, [sp, #-16]!    // Guardar el frame pointer y link register
    mov x29, sp                  // Establecer el frame pointer
    menuS:
        print clear, lenClear
        print menuPrincipal, lenMenuPrincipal
        print msgOpcion, lenOpcion
        read 0, opcion, 2
        //input

        LDR x10, =opcion
        LDRB w10, [x10]

        /*// Imprimir el segundo mensaje
        mov x0, 1          // Descriptor de archivo para stdout
        ldr x1, =opcion   // Dirección del mensaje
        mov x2, #5        // Longitud del mensaje
        mov x8, 64         // Número de llamada al sistema para write
        svc 0              // Llamada al sistema*/

        cmp w10, 49
        beq separadosPorComas

        cmp w10, 50
        beq cargarArchivoSCV

        cmp w10, 51
        beq end

        b invalido

        invalido:
            print erronea, lenErronea
            b cont

        separadosPorComas:
            print sumaComas, lenMultiplicacionText
            //beq opcion_separados               
            b cont

        cargarArchivoSCV:
            print cargacsv, lencargacsv
            // Imprimir mensaje para ingresar el nombre del archivo
            print msgFilename, lenMsgFilename
            read 0, filename, 50
            // Agregar caracter nulo al final del nombre del archivo
            LDR x0, =filename
            loop:
                LDRB w1, [x0], 1
                CMP w1, 10
                BEQ endLoop
                B loop

                endLoop:
                    MOV w1, 0
                    STRB w1, [x0, -1]!
            // funcion para abrir el archivo
            LDR x1, =filename
            BL openFile 

            // procedimiento para leer los numeros del archivo
            BL readCSV

            // funcion para cerrar el archivo
            BL closeFile 

            b end

        cont:
            read 0, filename, 50
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



openFile:
    // param: x1 -> filename
    MOV x0, -100
    MOV x2, 0
    MOV x8, 56
    SVC 0

    CMP x0, 0
    BLE op_f_error
    LDR x9, =fileDescriptor
    STR x0, [x9]
    B op_f_end

    op_f_error:
        print errorOpenFile, lenErrOpenFile
        read 0, opcion, 1

    op_f_end:
        RET


closeFile:
    LDR x0, =fileDescriptor
    LDR x0, [x0]
    MOV x8, 57
    SVC 0
    RET


readCSV:
    // code para leer numero y convertir
    LDR x10, =num    // Buffer para almacenar el numero
    LDR x11, =fileDescriptor
    LDR x11, [x11]

    rd_num:
        read x11, character, 1
        LDR x4, =character
        LDRB w3, [x4]
        CMP w3, 44
        BEQ rd_cv_num

        MOV x20, x0
        CBZ x0, rd_cv_num

        STRB w3, [x10], 1
        B rd_num

    rd_cv_num:
        LDR x5, =num
        LDR x8, =num
        LDR x12, =array

        STP x29, x30, [SP, -16]!

        BL atoi

        LDP x29, x30, [SP], 16

        LDR x12, =num
        MOV w13, 0
        MOV x14, 0

        cls_num:
            STRB w13, [x12], 1
            ADD x14, x14, 1
            CMP x14, 3
            BNE cls_num
            LDR x10, =num
            CBNZ x20, rd_num

    rd_end:
        print salto, lenSalto
        print readSuccess, lenReadSuccess
        //read 0, opcion, 2
        RET


atoi:
    // params: x5, x8 => buffer address, x12 => result address
    SUB x5, x5, 1
    a_c_digits:
        LDRB w7, [x8], 1
        CBZ w7, a_c_convert
        CMP w7, 10
        BEQ a_c_convert
        B a_c_digits

    a_c_convert:
        SUB x8, x8, 2
        MOV x4, 1
        MOV x9, 0

        a_c_loop:
            LDRB w7, [x8], -1
            CMP w7, 45
            BEQ a_c_negative

            SUB w7, w7, 48
            MUL w7, w7, w4
            ADD w9, w9, w7

            MOV w6, 10
            MUL w4, w4, w6

            CMP x8, x5
            BNE a_c_loop
            B a_c_end

        a_c_negative:
            NEG w9, w9

        a_c_end:
            LDR x13, =count
            LDR x13, [x13] // saltos
            MOV x14, 2
            MUL x14, x13, x14

            STRH w9, [x12, x14] // usando 16 bits

            ADD x13, x13, 1
            LDR x12, =count
            STR x13, [x12]

            RET





