.global do_numeros
.global openFile
.global closeFile
.global readCSV
.global atoi
.global sepados_comas
.global reset_variables

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
        .asciz "\nIngrese los numeros separados por comas: "
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
        .asciz "¡¡El archivo se ha leido correctamente!!\n"
        lenReadSuccess = .- readSuccess
    
    msgFilename:
        .asciz "\nIngrese el nombre del archivo: "
        lenMsgFilename = .- msgFilename

    readSuccess2:
        .asciz "Los datos se han leido Correctamente\n"
        lenReadSuccess2 = .- readSuccess2


.bss
    .global array   // Agregar esta línea
    .global count   // Agregar esta línea

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

    opracionCom:
        .zero 1024


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
    bl reset_variables
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
            BL sepados_comas               
            b end

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
        //read 0, opcion, 1
        b cont
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
    LDR x10, =num            // Cargar la dirección del buffer `num` para almacenar el número leído
    LDR x11, =fileDescriptor  // Cargar la dirección del descriptor de archivo
    LDR x11, [x11]           // Cargar el valor del descriptor de archivo

    rd_num:
        read x11, character, 1  // Leer 1 byte del archivo en el buffer `character`
        LDR x4, =character      // Cargar la dirección del buffer `character`
        LDRB w3, [x4]           // Cargar el carácter leído en el registro `w3`
        CMP w3, 44              // Comparar el carácter leído con el código ASCII de la coma (',')
        BEQ rd_cv_num           // Si es una coma, saltar a la conversión del número

        CMP w3, 10           // Comparar con el salto de línea (ASCII 10)
        BEQ retorno_Salto1    // Si es un salto de línea, procesar el último número pendiente

        MOV x20, x0             // Guardar el estado de retorno en `x20` para más adelante
        CBZ x0, rd_cv_num       // Si el valor de `x0` es 0, saltar a la conversión del número

        STRB w3, [x10], 1       // Almacenar el carácter leído en el buffer `num` y avanzar
        B rd_num                // Volver a leer otro carácter

    rd_cv_num:
        LDR x5, =num            // Cargar la dirección del buffer `num`
        LDR x8, =num            // Cargar nuevamente la dirección del buffer `num` (redundante, puede ser optimizado)
        LDR x12, =array         // Cargar la dirección del array donde se almacenarán los números convertidos

        STP x29, x30, [SP, -16]!  // Guardar los registros de enlace y base en la pila

        BL atoi                 // Llamar a la función `atoi` para convertir la cadena a un entero

        LDP x29, x30, [SP], 16  // Restaurar los registros de enlace y base desde la pila

        LDR x12, =num           // Cargar la dirección del buffer `num` nuevamente
        MOV w13, 0              // Inicializar el registro `w13` en 0 para limpiar el buffer `num`
        MOV x14, 0              // Inicializar el contador `x14` en 0

        cls_num:
            STRB w13, [x12], 1  // Escribir 0 en la posición actual del buffer `num` para limpiarlo
            ADD x14, x14, 1     // Incrementar el contador `x14`
            CMP x14, 3          // Comparar el contador con 3 (para limpiar 3 bytes del buffer)
            BNE cls_num         // Si no ha alcanzado 3, repetir el ciclo de limpieza
            LDR x10, =num       // Restaurar la dirección del buffer `num` para continuar leyendo más caracteres
            CBNZ x20, rd_num    // Si `x20` no es 0, continuar leyendo más caracteres del archivo
    
    retorno_Salto1:
        /*// Convertir el número pendiente cuando se encuentra una coma
        LDR x5, =num         // Cargar la dirección del buffer `num`
        LDR x8, =num         // Cargar la dirección del buffer `num`
        LDR x12, =array      // Cargar la dirección del array para almacenar los números

        STP x29, x30, [SP, -16]!  // Guardar registros de enlace y base en la pila
        BL atoi              // Llamar a atoi para convertir la cadena a un entero
        LDP x29, x30, [SP], 16  // Restaurar registros de enlace y base*/
        CBNZ x20, rd_cv_num 

    rd_end:
        print salto, lenSalto          // Imprimir un salto de línea
        print readSuccess, lenReadSuccess // Imprimir el mensaje de éxito en la lectura
        //read 0, opcion, 2           // (comentado) Leer opción (posiblemente para otra funcionalidad)
        RET                           // Retornar de la función




sepados_comas:
        // Imprimir el primer mensaje
        print sumaPorComas, lenSumaPorComas
        read 0, opracionCom, 1024 // Leer la operación completa

        LDR x10, =num            // Cargar la dirección del buffer `num` para almacenar el número leído
        LDR x4, =opracionCom   // Cargar la dirección de la cadena de entrada
        MOV x11, x4            // Mover la dirección base a x11
        MOV x15, 1024          // Tamaño máximo de la entrada

        rd_num2:
            LDRB w3, [x11], 1    // Leer un byte (carácter) desde `opracionCom` y avanzar el puntero
            CMP w3, 44           // Comparar el carácter leído con la coma (ASCII 44)
            BEQ rd_cv_num2       // Si es una coma, saltar a la conversión del número

            CMP w3, 10           // Comparar con el salto de línea (ASCII 10)
            BEQ retorno_Salto    // Si es un salto de línea, procesar el último número pendiente

            MOV x20, x0          // Guardar el estado de retorno en `x20`
            CBZ x0, rd_cv_num2    // Si `x0` es 0, convertir el número

            STRB w3, [x10], 1    // Almacenar el carácter leído en el buffer `num` y avanzar el puntero
            B rd_num2            // Volver a leer otro carácter

        rd_cv_num2:
            // Convertir el número pendiente cuando se encuentra una coma
            LDR x5, =num         // Cargar la dirección del buffer `num`
            LDR x8, =num         // Cargar la dirección del buffer `num`
            LDR x12, =array      // Cargar la dirección del array para almacenar los números

            STP x29, x30, [SP, -16]!  // Guardar registros de enlace y base en la pila
            BL atoi              // Llamar a atoi para convertir la cadena a un entero
            LDP x29, x30, [SP], 16  // Restaurar registros de enlace y base

            // Limpiar el buffer `num` para la próxima lectura
            LDR x12, =num           // Cargar la dirección del buffer `num` nuevamente
            MOV w13, 0           // Limpiar el buffer `num`
            MOV x14, 0           // Inicializar el contador

            cls_num2:
                STRB w13, [x12], 1  // Escribir 0 en la posición actual del buffer `num` para limpiarlo
                ADD x14, x14, 1     // Incrementar el contador `x14`
                CMP x14, 3          // Comparar el contador con 3 (para limpiar 3 bytes del buffer)
                BNE cls_num2         // Si no ha alcanzado 3, repetir el ciclo de limpieza
                LDR x10, =num       // Restaurar la dirección del buffer `num` para continuar leyendo más caracteres
                CBNZ x20, rd_num2    // Si `x20` no es 0, continuar leyendo más caracteres del archivo
        
        retorno_Salto:
            // Convertir el número pendiente cuando se encuentra una coma
            LDR x5, =num         // Cargar la dirección del buffer `num`
            LDR x8, =num         // Cargar la dirección del buffer `num`
            LDR x12, =array      // Cargar la dirección del array para almacenar los números

            STP x29, x30, [SP, -16]!  // Guardar registros de enlace y base en la pila
            BL atoi              // Llamar a atoi para convertir la cadena a un entero
            LDP x29, x30, [SP], 16  // Restaurar registros de enlace y base

        rd_end2:
            print salto, lenSalto  // Imprimir el salto de línea
            print readSuccess2, lenReadSuccess2 // Mensaje de éxito
            RET// Retornar de la función



// Función para convertir una cadena ASCII a entero con la validación de signos
atoi:
    // Parámetros: x5 = dirección del buffer, x8 = dirección donde se comenzará a leer, x12 = dirección del resultado
    SUB x5, x5, 1                  // Ajusta el puntero del buffer restando 1 para empezar desde el último carácter válido
    a_c_digits:                     // Etiqueta para el inicio de la lectura de dígitos
        LDRB w7, [x8], 1            // Carga un byte (carácter) del buffer en w7 y avanza el puntero x8
        CBZ w7, a_c_convert          // Si el byte leído es 0 (fin de cadena), salta a la conversión
        CMP w7, 10                   // Compara el carácter leído con el salto de línea (ASCII 10)
        BEQ a_c_convert              // Si es un salto de línea, salta a la conversión
        B a_c_digits                 // Repite la lectura de dígitos

    a_c_convert:                     // Etiqueta para la conversión de la cadena a entero
        SUB x8, x8, 2                // Ajusta el puntero para que apunte al último carácter leído
        MOV x4, 1                    // Inicializa el multiplicador para la conversión (10^0)
        MOV w9, 0                    // Inicializa el resultado acumulado en w9 a 0

        a_c_loop:                    // Etiqueta para el bucle de conversión
            LDRB w7, [x8], -1        // Lee el carácter anterior del buffer y retrocede el puntero
            CMP w7, 45               // Compara el carácter con el signo negativo (ASCII 45)
            BEQ a_c_negative         // Si es un signo negativo, salta a la lógica para manejarlo

            SUB w7, w7, 48           // Convierte el carácter ASCII a número (ASCII 0 es 48)
            MUL w7, w7, w4           // Multiplica el dígito por el multiplicador actual (10^n)
            ADD w9, w9, w7           // Suma el resultado al total acumulado

            MOV w6, 10                // Carga el valor 10 en w6
            MUL w4, w4, w6            // Multiplica el multiplicador por 10 para la siguiente posición

            CMP x8, x5                // Compara el puntero actual con el inicio del buffer
            BNE a_c_loop              // Si no hemos llegado al inicio, repite el bucle

            B a_c_end                 // Salta al final de la función

        a_c_negative:                 // Etiqueta para manejar el caso negativo
            NEG w9, w9                // Negar el resultado acumulado para convertirlo a negativo

        a_c_end:                      // Etiqueta para el final de la función
            LDR x13, =count           // Carga la dirección de la variable de conteo
            LDR x13, [x13]            // Carga el valor actual de saltos
            MOV x14, 4                // Inicializa x14 para el desplazamiento del resultado
            MUL x14, x13, x14          // Multiplica el conteo por 4 para calcular el desplazamiento en bytes

            STR w9, [x12, x14]        // Almacena el resultado en la dirección de resultado ajustada por el desplazamiento

            ADD x13, x13, 1           // Incrementa el contador de saltos
            LDR x12, =count            // Carga nuevamente la dirección de la variable de conteo
            STR x13, [x12]            // Almacena el nuevo valor del contador de saltos

            RET                        // Retorna de la función



// Rutina para reiniciar array y count
reset_variables:
    // Reiniciar el array a cero
    LDR x0, =array      // Cargar la dirección de array
    MOV x1, 1024      // Tamaño de array en bytes
    MOV x2, 0          // Valor a almacenar (cero)

    reset_array_loop:
        STRB w2, [x0], 1   // Almacenar cero en la dirección actual y avanzar
        SUBS x1, x1, 1     // Decrementar el contador
        BNE reset_array_loop // Si no ha llegado a cero, repetir

        // Reiniciar count a cero
        LDR x0, =count      // Cargar la dirección de count
        MOV x1, 8          // Tamaño de count en bytes

    reset_count_loop:
        STRB w2, [x0], 1   // Almacenar cero en la dirección actual y avanzar
        SUBS x1, x1, 1     // Decrementar el contador
        BNE reset_count_loop // Si no ha llegado a cero, repetir

        // Salir de la rutina
        RET





