
.global do_Import

.extern arreglo
.extern opcion

.data
    salto:
        .asciz "\n"
        lenSalto = .- salto

    espacio:
        .asciz "\t"
        lenEspacio = .- espacio

    espacio2:
        .asciz " "
        lenEspacio2 = .- espacio2

    dpuntos:
        .asciz ":"
        lenDpuntos = .- dpuntos

    cmdimp:
        .asciz "IMPORTAR"

    cmdsep:
        .asciz "SEPARADO POR COMA"

    comado_tabular:
        .asciz "SEPARADO POR TABULADOR"

    errorImport:
        .asciz "Error en el Comando De Importación"
        lenError = .- errorImport

    errorOpenFile:
        .asciz "Error al abrir el archivo\n"
        lenErrOpenFile = .- errorOpenFile

    getIndexMsg:
        .asciz "Ingrese la columna para el encabezado "
        lenGetIndexMsg = .- getIndexMsg

    readSuccess:
        .asciz "El archivo se ha leido Correctamente\n"
        lenReadSuccess = .- readSuccess
    
    msgOpcion:
        .asciz "\nIngrese el comando para abrir un archivo: "
        lenOpcion = .- msgOpcion

.bss
    val:
        .space 2

    /*bufferComando:
        .zero 50*/

    filename:
        .space 100

    buffer:
        .zero 1024

    fileDescriptor:
        .space 8

    listIndex:
        .zero 6

    num:
        .space 10

    col_imp:
        .space 1

    character:
        .space 2

    count:
        .zero 8
    

.text
.macro print stdout, reg, len
    MOV x0, \stdout
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

.macro read stdin, reg, len
    MOV x0, \stdin
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm



//Esta funcion realiza el reconocimiento del comando: IMPORT <nombre_archivo.csv> SEPARADO POR COMA
proc_import:
    LDR x0, =cmdimp //Aca se encuantra el comando IMPORT
    LDR x1, =opcion //Aca se carga un bufer de 50 bytes

    imp_loop:
        LDRB w2, [x0], 1 //Se carga el primer caracter de IMPORT
        LDRB w3, [x1], 1 //Se carga un caracter del bufercomand

        CBZ w2, imp_filename //Comparar y saltar si es cero, es decir un espacio en blanco

        CMP w2, w3
        BNE imp_error //  saltar si NO es igual w2 con w3

        B imp_loop //Si todo lo anterior no se cumple repite el ciclo

        imp_error: //Aca se imprime un error por si el comando IMPORT no esta bien escrito
            print 1, errorImport, lenError //Imprime el mensaje de error
            B end_proc_import //Finaliza la funcion de reconocer el comando IMPORT

    imp_filename: //Esta etiqueta obtiene el nombre del archivo
        LDR x0, =filename //Carga la direccion del buffer donde se almacena el nombre del archivo
        imp_file_loop:
            LDRB w2, [x1], 1 //Carga el primer bite del nombre del archivo

            CMP w2, 32 //Comparamos con el caracter de espacio en blanco
            BEQ cont_imp_file //saltar si es igual al bite a un espacio en blanco

            STRB w2, [x0], 1 //Carga el bite del nombre a la variable filename
            B imp_file_loop //Regresa al bucle hasta que se encuentre un espacio en blanco

        cont_imp_file: //Aca se compara el final de la cadena para ver si el comando final es correcto
            STRB wzr, [x0]//Carga el valor de cero al filename
            LDR x0, =cmdsep //Caraga la palabra: SEPARADO POR COMA
            cont_imp_loop:
                LDRB w2, [x0], 1 //Carga la primera letre de SEPARADO POR COMA
                LDRB w3, [x1], 1 //Se carga el primer valor del bufer de entrada 
                
                CBZ w2, end_proc_import //Comparar y saltar si es cero el caracter de w2
                B cont_imp_loop //De lo contrario repite el bucle

                CMP w2, w3
                BNE comparar_tabulador //Saltar si NO es igual w2 con w3

            //Aca se compara si la cadena es SEPARADO POR TABULADOR
            STRB wzr, [x0]//Carga el valor de cero al filename
            LDR x0, =comado_tabular //Caraga la palabra: SEPARADO POR TABULADOR
            comparar_tabulador:
                LDRB w2, [x0], 1 //Carga la primera letre de SEPARADO POR TABULADOR
                LDRB w3, [x1], 1 //Se carga el primer valor del bufer de entrada

                CBZ w2, end_proc_import //Comparar y saltar si es cero el caracter de w2
                B comparar_tabulador //De lo contrario repite el bucle

                CMP w2, w3
                BNE imp_error //Saltar si NO es igual w2 con w3

    end_proc_import://Llegamos al final de la cadena
        RET//Retornamos a la rutina donde fue llamada



//Esta funcion se encaraga de guradar los datos del csv al array a mostrar
import_data:
    LDR x1, =filename //Carga el nomnre del archivo
    STP x29, x30, [SP, -16]! //Guardamos el estack pionter
    BL openFile //Abrimos el archivo
    LDP x29, x30, [SP], 16 //Retornamos el estack pionter

    LDR x25, =buffer
    MOV x10, 0
    LDR x11, =fileDescriptor //Aca se carga el descriptor del archivo avierto
    LDR x11, [x11] //Carga el valor del file descriptor
    MOV x17, 0 //contador de columnas
    LDR x15, =listIndex

    read_head: //En esta parte se lee las cabeceras del archivo .csv
        read x11, character, 1
        LDR x4, =character
        LDRB w2, [x4] //Aca carga el primer caracter del arhivo

        CMP w2, 44 //compara el caracter con el valor de coma (,)
        BEQ getIndex //salta si es igual a una coma: w2 == ,

        CMP w2, 9 //compara el caracter con el valor del tabulador (\t)
        BEQ getIndex //salta si es igual a un tabulador: w2 == \t

        CMP w2, 10 //Compara si es un salto de linea
        BEQ quitar //salta si es igual a un salto de linea: w2 == \n y le quita un espacio 

        STRB w2, [x25], 1 //Si no se cumple nada de lo anterior carga el primer caracter a la variable buffer
        ADD x10, x10, 1 //Incrementa el valor de x10, para posteriormente imprimir la palabra
        B read_head //Reiniciamos el ciclo

        quitar:
            sub x10,x10,1//aca se le quita un espacio a la longuitud por que si no imprime el salto de linea

        getIndex:
            print 1, getIndexMsg, lenGetIndexMsg //Imprime la palabra "Ingrese la columna para el encabezado"
            print 1, buffer, x10    //Imprime la palabra del encavezado
            print 1, dpuntos, lenDpuntos //Imprime los dos puntos
            print 1, espacio2, lenEspacio2 //Imprime un espacio en blanco

            LDR x4, =character //Carga la direccion de la variable donde se encuentra el texto del csv
            LDRB w7, [x4] //Carga un caracter al registro w7

            read 0, character, 2 //Lee el caracter

            LDR x4, =character //Carga la direccion 
            LDRB w2, [x4] //Carga un bite del bufer
            SUB w2, w2, 65 //Como vamos a trabajar con las Columnas como letras A=65, por eso se le resta a la letra que venga 
            
            STRB w2, [x15], 1 //Carga el primer bite a la variable index
            ADD x17, x17, 1 //Incrementa el contador de x17 que son las columnas

            CMP w7, 10 //Compara el caracter con el salto de linea \n
            BEQ end_header //Salta si es igual a un salto de linea w7==\n

            LDR x25, =buffer //Carga la direcion del buffer para la palabra nuevamente a x25
            MOV x10, 0 //Reinicia el contador de caracteres de la palabra a imprimir, de la columna
            B read_head //Reinicia el ciclo de nuevo 

        end_header: //Esto es cuando llega al final del reocorrido de las columnas
            STP x29, x30, [SP, -16]! //Se gurada el stack pointer
            BL readCSV  //Se le el archivo con el contenido 
            LDP x29, x30, [SP], 16 //Se restaura el stack pionter

        RET //Se retorna al principio de la llamada
            

readCSV:
    LDR x10, =num               // Cargar la dirección de 'num' en el registro x10
    LDR x11,  =fileDescriptor    // Cargar la dirección de 'fileDescriptor' en x11
    LDR x11, [x11]              // Cargar el valor de 'fileDescriptor' en x11
    MOV x21, 0                  // Inicializar el contador de filas en 0
    LDR x15, =listIndex         // Cargar la dirección de 'listIndex' (contador de columnas) en x15

    rd_num:
        read x11, character, 1  // Leer un carácter desde 'fileDescriptor' en 'character'
        LDR x4, =character      // Cargar la dirección de 'character' en x4
        LDRB w3, [x4]           // Cargar el byte de 'character' en el registro w3

        CMP w3, 44              // Comparar si el carácter es una coma (',')
        BEQ rd_cv_num           // Si es coma, saltar a 'rd_cv_num'

        CMP w3, 9              // Comparar si el carácter es una tabulador ('\t')
        BEQ rd_cv_num           // Si es tabulador, saltar a 'rd_cv_num'

        CMP w3, 10              // Comparar si el carácter es un salto de línea (newline)
        BEQ poner_nulo           // Si es newline, saltar a 'rd_cv_num'

        MOV x25, x0             // Mover el valor de x0 a x25 (almacenar el valor original de x0)
        CBZ x0, rd_cv_num       // Si x0 es 0 (cadena vacía), saltar a 'rd_cv_num'

        STRB w3, [x10], 1       // Almacenar el carácter leído en la dirección de 'num' y avanzar el puntero
        B rd_num                // Volver a leer el siguiente carácter
    
    poner_nulo:
        STRB WZR, [x10, -1]           // Reemplazar '\n' con un carácter nulo

    rd_cv_num:
        LDR x5, =num            // Cargar la dirección de 'num' en x5
        LDR x8, =num            // Cargar la dirección de 'num' en x8

        STP x29, x30, [SP, -16]! // Guardar los registros x29 y x30 en la pila
        BL atoi                 // Llamar a la función 'atoi' para convertir la cadena numérica
        LDP x29, x30, [SP], 16  // Restaurar los registros x29 y x30 desde la pila

        LDRB w16, [x15], 1      // Obtener el valor de la columna desde 'listIndex'

        LDR x20, =arreglo       // Cargar la dirección del arreglo donde se almacenan los datos
        MOV x22, 12              // Multiplicar la fila actual por 12 (supuesto tamaño de las filas)
        MUL x22, x21, x22       // Realizar la multiplicación para calcular el offset
        ADD x22, x16, x22       // Sumar el valor de la columna al offset
        STR x9, [x20, x22, LSL #3] // Almacenar el valor en el arreglo, ajustando el offset según el tamaño

        LDR x12, =num           // Cargar la dirección de 'num' en x12
        MOV w13, 0              // Inicializar w13 en 0
        MOV x14, 0              // Inicializar x14 en 0
        
        LDR x20, =listIndex     // Cargar la dirección de 'listIndex' en x20
        SUB x20, x15, x20       // Restar el índice actual de 'listIndex'
        CMP x20, x17            // Comparar con el valor en x17 (tamaño esperado de columnas)
        BNE cls_num             // Si no son iguales, saltar a 'cls_num'

        LDR x15, =listIndex     // Reiniciar el índice de columnas
        ADD x21, x21, 1         // Incrementar el contador de filas

    cls_num:
        STRB w13, [x12], 1      // Almacenar 0 en la dirección de 'num'
        ADD x14, x14, 1         // Incrementar x14 en 1 (contador de ceros añadidos)
        CMP x14, 9              // Comparar si x14 ha alcanzado 7
        BNE cls_num             // Si no ha alcanzado 7, seguir limpiando
        LDR x10, =num           // Reiniciar el puntero de 'num'
        CBNZ x25, rd_num        // Si x25 no es 0, volver a 'rd_num' para leer más caracteres

    rd_end:
        print 1, salto, lenSalto // Imprimir un salto de línea
        print 1, readSuccess, lenReadSuccess // Imprimir el mensaje de éxito en la lectura
        read 0, character, 2    // Leer dos caracteres de entrada
        RET                     // Retornar del procedimiento




openFile:
    // param: x1 => filename
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
        print 1, errorOpenFile, lenErrOpenFile
        read 0, character, 2
    
    op_f_end:
        RET



closeFile:
    LDR x0, =fileDescriptor
    LDR x0, [x0]
    MOV x8, 57
    SVC 0
    RET


//Esta es la subrutina principal 
do_Import:
    stp x29, x30, [sp, #-16]!    // Guardar el frame pointer y link register
    mov x29, sp                  // Establecer el frame pointer

    //print 1, msgOpcion, lenOpcion //Aca se manda a llamar al mensaje de Inresar un comando
    //read 0, opcion, 50 //Se almacena el comando en la variable bufferComand

    BL proc_import //En esta parte se obtiene el nombre del archivo

    BL import_data //En esta parte se abre el archivo y se muestra el contenido del mismo en la tabla

    BL closeFile
    ldp x29, x30, [sp], #16      // Restaurar el frame pointer y link register
    ret                          // Regresar al punto donde se llamó  








//******************************Aca se encuentra el area de conversio de entero a text y texto a entero */

// Función para convertir un entero con la validación de signos a cadena ASCII
itoa:
    // params: x0 => number, x1 => buffer address
    MOV x10, 0  // contador de digitos a imprimir
    MOV x12, 0  // flag para indicar si hay signo menos

    CBZ x0, i_zero

    MOV x2, 1
    defineBase:
        CMP x2, x0
        MOV x5, 0
        BGT cont
        MOV x5, 10
        MUL x2, x2, x5
        B defineBase

    cont:
        CMP x0, 0  // Numero a convertir
        BGT i_convertirAscii
        B i_negative

    i_zero:
        ADD x10, x10, 1
        MOV w5, 48
        STRB w5, [x1], 1
        B i_endConversion

    i_negative:
        MOV  x12, 1
        MOV w5, 45
        STRB w5, [x1], 1
        NEG x0, x0

    i_convertirAscii:
        CBZ x2, i_endConversion
        UDIV x3, x0, x2
        CBZ x3, i_reduceBase

        MOV w5, w3
        ADD w5, w5, 48
        STRB w5, [x1], 1
        ADD x10, x10, 1

        MUL x3, x3, x2
        SUB x0, x0, x3

        CMP x2, 1
        BLE i_endConversion

        i_reduceBase:
            MOV x6, 10
            UDIV x2, x2, x6

            CBNZ x10, i_addZero
            B i_convertirAscii

        i_addZero:
            CBNZ x3, i_convertirAscii
            ADD x10, x10, 1
            MOV w5, 48
            STRB w5, [x1], 1
            B i_convertirAscii

    i_endConversion:
        ADD x10, x10, x12
        print 1, num, x10
        RET



// Función para convertir cadena ASCII a un entero con la validación de signos
atoi:
    // params: x5, x8 => buffer address
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
            RET




