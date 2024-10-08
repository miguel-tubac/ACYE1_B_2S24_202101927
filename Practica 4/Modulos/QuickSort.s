.global do_quick

.extern array
.extern count
.global quicksort

//.global copy_array
//.global copy_array2
//.global itoa

.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear

    menuPrincipal:
        .asciz "¬¬¬¬¬¬¬¬¬ Menu Quick Sort ¬¬¬¬¬¬¬¬¬\n"
        .asciz "1. Ordenamiento de manera Acendente\n"
        .asciz "2. Ordenamiento de manera Decendente\n"
        .asciz "3. Regresar..\n"
        lenMenuPrincipal = .- menuPrincipal

    msgOpcion:
        .asciz "\nIngrese Una Opcion: "
        lenOpcion = .- msgOpcion

    sumaComas:
        .asciz "...Ingresando Ordenamiento de manera Acendente...\n"
        lenMultiplicacionText = . - sumaComas

    cargacsv:
        .asciz "...Ingresando Ordenamiento de manera Decendente...\n"
        lencargacsv = . - cargacsv

    erronea:
        .asciz "\n...Opción no válida, intenta de nuevo..."
        lenErronea = . - erronea

    precionarEnter:
        .asciz "\n\n...Presione enter para continuar..."
        lenPrecionarEnter = . - precionarEnter

    regresandoInicio:
        .asciz "\n...Presione enter para regresar..."
        lenRegresandoInicio = . - regresandoInicio

    visualizar:
        .asciz "\nIngrese 1 si deceas ver los pasos y 0 si no: "
        lenvisualizar = . - visualizar
    
    espacio:
        .asciz " "
        lenEspacio = .- espacio
    
    newline:
        .asciz "\n"
        lennewline = . - newline

    resulta:
        .asciz "\nResultado: "
        lenResultado = . - resulta

    pasosim:
        .asciz "\nPaso "
        lenpasosim = . -pasosim

    dospuntos:
        .asciz " : "
        lendospuntos = . - dospuntos
    
    conjInicial: 
        .asciz "\nConjunto inicial: "
        lenconjInicial = . - conjInicial

    pivote: 
        .asciz "\nDividiendo por pivote ("
        lenpivote = . - pivote

    finpivote:
        .asciz "):"
        lenfinpivote = . - finpivote


.bss
    opcion:
        .space 5   // => El 5 indica cuantos BYTES se reservaran para la variable opcion
    num:
        .space 50

    filename:
        .zero 50
    
    opcion2:
        .space 5

    num1:
        .space 50

    array2:
        .skip 1024


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
do_quick:
    stp x29, x30, [sp, #-16]!    // Guardar el frame pointer y link register
    mov x29, sp                  // Establecer el frame pointer

    bl copy_array
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
        beq acendente

        cmp w10, 50
        beq decendente

        cmp w10, 51
        beq end

        b invalido

        invalido:
            print erronea, lenErronea
            b cont

        acendente:
            bl copy_array2
            print sumaComas, lenMultiplicacionText
            //beq opcion_separados 
            
            print visualizar, lenvisualizar              
            read 0, opcion2, 2
            LDR x10, =opcion2
            LDRB w10, [x10]

            cmp w10,48
            beq no_visualizar

            cmp w10,49
            beq quicksort_Pasos_inicio

            b invalido

        decendente:
            bl copy_array2
            print cargacsv, lencargacsv
            // Imprimir mensaje para ingresar el nombre del archivo
            print visualizar, lenvisualizar              
            read 0, opcion, 2
            LDR x10, =opcion
            LDRB w10, [x10]

            cmp w10,48
            beq no_visualizar2

            cmp w10,49
            beq quicksort_Pasos_inicio2_Desendente
            
            b invalido
        cont:
            read 0, filename, 50
            b menuS

    end:
        bl copy_array2//esto es para que el array original mantenga el valor con que se inicio
        // Mostrar el precionar enter
        mov x0, 1              // Descriptor de archivo para stdout
        ldr x1, =regresandoInicio       // Dirección de nueva línea
        mov x2, lenRegresandoInicio             // Tamaño de nueva línea
        mov x8, 64             // Número de llamada al sistema para write
        svc 0                  // Llamada al sistema

        ldp x29, x30, [sp], #16      // Restaurar el frame pointer y link register
        ret



//***************************************** Inicio del Quick Sort Acendente**************
no_visualizar:
    LDR x0, =array
    MOV x1, 0
    LDR x2, =count
    LDR x2, [x2] // length => cantidad de numeros leidos del csv
    SUB x2, x2, 1
    bl quicksort
    
    // recorrer array y convertir a ascii
    LDR x9, =count
    LDR x9, [x9] // length => cantidad de numeros leidos del csv
    MOV x7, 0
    LDR x15, =array

    print resulta, lenResultado
    loop_array:
        LDR w0, [x15], 4
        LDR x1, =num
        BL itoa

        print num, x10
        print espacio, lenEspacio

        ADD x7, x7, 1
        CMP x9, x7
        BNE loop_array

    print newline, lennewline
    print precionarEnter, lenPrecionarEnter
    read 0, filename, 50
    b menuS



// Función Quick Sort
quicksort:
    // x0 = array [direccion de memoria]
    // x1 = inicio
    // x2 = fin

    // if (inicio >= fin)
    CMP x1, x2
    BGE quicksort_final
    // endif
    LDR w3, [x0, x1, LSL 2]  // pivote -> w3 | pivote = array[inicio]

    // izq = x4, der = x5
    ADD x4, x1, 1   // izq = inicio + 1
    MOV x5, x2      // der = fin

    // while(izq <= der)
    quicksort_while_principal:

        // while(izq <= fin && array[izq] < pivote)
        quicksort_while_interno_1:

            // primera condicion: izq <= fin
            CMP x4, x2
            BGT quicksort_while_interno_2
            // segunda condicion: array[izq] < pivote
            LDR w6, [x0, x4, LSL 2]    // array[izq]
            CMP w6, w3
            BGE quicksort_while_interno_2
            ADD x4, x4, 1   // izq++
            B quicksort_while_interno_1


        // while(der > inicio && array[der] >= pivote)
        quicksort_while_interno_2:
            // primera condicion: der > inicio
            CMP x5, x1
            BLE quicksort_intercambio
            // segunda condicion: array[der] >= pivote
            LDR w6, [x0, x5, LSL 2]    // array[der]
            CMP w6, w3
            BLT quicksort_intercambio
            SUB x5, x5, 1   // der--
            B quicksort_while_interno_2


        // if(izq < der)
        quicksort_intercambio:

            // condicion: izq < der
            CMP x4, x5
            BGE quicksort_while_continuacion
            // hacer intercambio
            LDR w6, [x0, x4, LSL 2]    // array[izq]
            LDR w7, [x0, x5, LSL 2]    // array[der]
            STR w7, [x0, x4, LSL 2]    // array[izq] = array[der]
            STR w6, [x0, x5, LSL 2]    // array[der] = array[izq]

        // condicion while principal: izq <= der
        quicksort_while_continuacion:
            CMP x4, x5
            BLE quicksort_while_principal
            
    // bloque condicionante: if(der > inicio)
    CMP x5, x1
    BLE quicksort_recursividad

    // hacer intercambio
    LDR w6, [x0, x1, LSL 2]    // array[inicio]
    LDR w7, [x0, x5, LSL 2]    // array[der]

    STR w7, [x0, x1, LSL 2]    // array[inicio] = array[der]
    STR w6, [x0, x5, LSL 2]    // array[der] = array[inicio]

    quicksort_recursividad:
        // PRIMERA RECURSIVIDAD
        // almacenar en la pila los registros  x1 = inicio x5 = der  x2 = fin
        STP x1, x2, [SP, #-16]!
        STR x5, [SP, #-16]!

        // actualizar parametro: fin = der - 1
        SUB x2, x5, 1
        
        // almacenar puntero del progrma en la pila
        STP x29, x30, [SP, #-16]!

        // primera llamada recursiva: quicksort(array, inicio, der - 1)
        BL quicksort

        // recuperar puntero del programa de la pila
        LDP x29, x30, [SP], #16

        // recuperar registro  x1 = inicio x5 = der  x2 = fin
        LDR x5, [SP], 16
        LDP x1, x2, [SP], 16

        // SEGUNDA RECURSIVIDAD
        // almacenar en la pila los registros  x1 = inicio x5 = der  x2 = fin
        STP x1, x2, [SP, -16]!
        STR x5, [SP, -16]!

        // actualizar parametro: inicio = der + 1
        ADD x1, x5, 1
        
        // almacenar puntero del progrma en la pila
        STP x29, x30, [SP, -16]!

        // primera llamada recursiva: quicksort(array, inicio, der - 1)
        BL quicksort

        // recuperar puntero del programa de la pila
        LDP x29, x30, [SP], 16

        // recuperar registros x1 = inicio x5 = der  x2 = fin
        LDR x5, [SP], 16
        LDP x1, x2, [SP], 16

    quicksort_final:
        RET

quicksort_Pasos_inicio:
    MOV x11, 0                      // Inicializar contador
    bl print_array           // Llamar a la rutina para imprimir el arreglo
    //fin
    //cargamos los valores iniciales
    LDR x0, =array
    MOV x1, 0
    LDR x2, =count
    LDR x2, [x2] // length => cantidad de numeros leidos del csv
    SUB x2, x2, 1
    // almacenar puntero del progrma en la pila
    STP x29, x30, [SP, #-16]!

    bl quicksort_Pasos
    // recuperar puntero del programa de la pila
    LDP x29, x30, [SP], #16

    print newline, lennewline
    print precionarEnter, lenPrecionarEnter
    read 0, filename, 50
    b menuS

    // Función Quick Sort
    quicksort_Pasos:
        // x0 = array [direccion de memoria]
        // x1 = inicio
        // x2 = fin

        // if (inicio >= fin)
        CMP x1, x2
        BGE quicksort_final1
        // endif
        LDR w3, [x0, x1, LSL 2]  // pivote -> w3 | pivote = array[inicio]

        // izq = x4, der = x5
        ADD x4, x1, 1   // izq = inicio + 1
        MOV x5, x2      // der = fin

        // while(izq <= der)
        quicksort_while_principal1:

            // while(izq <= fin && array[izq] < pivote)
            quicksort_while_interno_11:

                // primera condicion: izq <= fin
                CMP x4, x2
                BGT quicksort_while_interno_21
                // segunda condicion: array[izq] < pivote
                LDR w6, [x0, x4, LSL 2]    // array[izq]
                CMP w6, w3
                BGE quicksort_while_interno_21
                ADD x4, x4, 1   // izq++
                B quicksort_while_interno_11


            // while(der > inicio && array[der] >= pivote)
            quicksort_while_interno_21:
                // primera condicion: der > inicio
                CMP x5, x1
                BLE quicksort_intercambio1
                // segunda condicion: array[der] >= pivote
                LDR w6, [x0, x5, LSL 2]    // array[der]
                CMP w6, w3
                BLT quicksort_intercambio1
                SUB x5, x5, 1   // der--
                B quicksort_while_interno_21


            // if(izq < der)
            quicksort_intercambio1:

                // condicion: izq < der
                CMP x4, x5
                BGE quicksort_while_continuacion1
                // hacer intercambio
                LDR w6, [x0, x4, LSL 2]    // array[izq]
                LDR w7, [x0, x5, LSL 2]    // array[der]
                STR w7, [x0, x4, LSL 2]    // array[izq] = array[der]
                STR w6, [x0, x5, LSL 2]    // array[der] = array[izq]

                STP x29, x30, [SP, #-16]!
                //Aca la imprecion del pivote
                bl print_pivote
                LDP x29, x30, [SP], #16

                STP x29, x30, [SP, #-16]!
                ADD x11, x11 , 1 //x11 ++
                bl print_array           // Llamar a la rutina para imprimir el arreglo
                LDP x29, x30, [SP], #16
            // condicion while principal: izq <= der
            quicksort_while_continuacion1:
                CMP x4, x5
                BLE quicksort_while_principal1
                
        // bloque condicionante: if(der > inicio)
        CMP x5, x1
        BLE quicksort_recursividad1

        // hacer intercambio
        LDR w6, [x0, x1, LSL 2]    // array[inicio]
        LDR w7, [x0, x5, LSL 2]    // array[der]

        STR w7, [x0, x1, LSL 2]    // array[inicio] = array[der]
        STR w6, [x0, x5, LSL 2]    // array[der] = array[inicio]

        STP x29, x30, [SP, #-16]!
        //Aca la imprecion del pivote
        bl print_pivote
        LDP x29, x30, [SP], #16

        STP x29, x30, [SP, #-16]!
        ADD x11, x11 , 1 //x11 ++
        bl print_array           // Llamar a la rutina para imprimir el arreglo
        LDP x29, x30, [SP], #16

        quicksort_recursividad1:
            // PRIMERA RECURSIVIDAD
            // STP x0, x1, [sp, #-16]! 
            // almacenar en la pila los registros  x1 = inicio x5 = der  x2 = fin
            STP x1, x2, [SP, #-16]!
            STR x5, [SP, #-16]!

            // actualizar parametro: fin = der - 1
            SUB x2, x5, 1
            
            // almacenar puntero del progrma en la pila
            STP x29, x30, [SP, #-16]!
            
            // primera llamada recursiva: quicksort(array, inicio, der - 1)
            BL quicksort_Pasos

            // recuperar puntero del programa de la pila
            LDP x29, x30, [SP], #16

            // recuperar registro  x1 = inicio x5 = der  x2 = fin
            LDR x5, [SP], #16
            LDP x1, x2, [SP], #16

            // SEGUNDA RECURSIVIDAD
            // almacenar en la pila los registros  x1 = inicio x5 = der  x2 = fin
            STP x1, x2, [SP, #-16]!
            STR x5, [SP, #-16]!

            // actualizar parametro: inicio = der + 1
            ADD x1, x5, 1
            
            // almacenar puntero del progrma en la pila
            STP x29, x30, [SP, #-16]!
            
            // primera llamada recursiva: quicksort(array, inicio, der - 1)
            BL quicksort_Pasos

            // recuperar puntero del programa de la pila
            LDP x29, x30, [SP], #16
            
            // recuperar registros x1 = inicio x5 = der  x2 = fin
            LDR x5, [SP], #16
            LDP x1, x2, [SP], #16

        quicksort_final1:
            ret



print_pivote:
    STP x29, x30, [sp, #-16]!      // Guardar Frame Pointer (x29) y Link Register (x30)
    MOV x29, sp                    // Actualizar el Frame Pointer al valor de sp
    STP x0, x1, [sp, #-16]!        // Guardar x0 y x1 en la pila
    STP x6, x7, [sp, #-16]!       // Guardar registros adicionales
    STP x2, x3, [sp, #-16]!        // Guardar x2 y x3 (usados para itoa)
    STP x4, x5, [sp, #-16]!        // Guardar x4 y x5 (si se usan en itoa o la rutina actual)

    print pivote, lenpivote
    MOV x0, x3
    LDR x1, =num1
    BL itoa                        // Llamada a itoa para convertir el número
    print num1, x10
    print finpivote, lenfinpivote

    // Imprimir nueva línea
    print newline, lennewline

    LDP x4, x5, [sp], #16          // Restaurar x4 y x5
    LDP x2, x3, [sp], #16          // Restaurar x2 y x3
    LDP x6, x7, [sp], #16         // Restaurar x9 y x10
    LDP x0, x1, [sp], #16          // Restaurar x0 y x1
    LDP x29, x30, [sp], #16        // Restaurar Frame Pointer y Link Register

    ret                            // Retornar de la función



print_array:
    STP x29, x30, [sp, #-16]!      // Guardar Frame Pointer (x29) y Link Register (x30)
    MOV x29, sp                    // Actualizar el Frame Pointer al valor de sp
    STP x0, x1, [sp, #-16]!        // Guardar x0 y x1 en la pila
    STP x6, x7, [sp, #-16]!       // Guardar registros adicionales
    STP x2, x3, [sp, #-16]!        // Guardar x2 y x3 (usados para itoa)
    STP x4, x5, [sp, #-16]!        // Guardar x4 y x5 (si se usan en itoa o la rutina actual)

    LDR x14, =count                // Cargar el valor de count (número de elementos)
    LDR x14, [x14]                 // Leer cantidad de números leídos del CSV
    MOV x7, 0                      // Inicializar contador
    LDR x15, =array                // Cargar la dirección del array

    CMP x11, 0
    beq inciando

    print pasosim, lenpasosim
    MOV x0, x11
    LDR x1, =num1
    BL itoa                        // Llamada a itoa para convertir el número
    print num1, x10
    print dospuntos, lendospuntos
    b loop_array2

    inciando:
        print conjInicial, lenconjInicial

    loop_array2:
        LDR w0, [x15], 4               // Cargar siguiente valor del array (elemento de 32 bits)
        LDR x1, =num                   // Apuntar el buffer a la cadena "num"

        BL itoa                        // Llamada a itoa para convertir el número
        print num, x10
        print espacio, lenEspacio      // Imprimir espacio entre los números

        ADD x7, x7, 1                  // Incrementar el contador
        CMP x14, x7                    // Comparar el contador con el número total
        BNE loop_array2                // Si no se ha terminado, repetir

        // Imprimir nueva línea
    print newline, lennewline

    LDP x4, x5, [sp], #16          // Restaurar x4 y x5
    LDP x2, x3, [sp], #16          // Restaurar x2 y x3
    LDP x6, x7, [sp], #16         // Restaurar x9 y x10
    LDP x0, x1, [sp], #16          // Restaurar x0 y x1
    LDP x29, x30, [sp], #16        // Restaurar Frame Pointer y Link Register

    ret                            // Retornar de la función

//***************************************** Fin del Quick Sort Acendente**************



//***************************************** Inicio del Quick Sort Decendete**************


no_visualizar2:
    LDR x0, =array
    MOV x1, 0
    LDR x2, =count
    LDR x2, [x2] // length => cantidad de numeros leidos del csv
    SUB x2, x2, 1
    bl quicksort2
    
    // recorrer array y convertir a ascii
    LDR x9, =count
    LDR x9, [x9] // length => cantidad de numeros leidos del csv
    MOV x7, 0
    LDR x15, =array

    print resulta, lenResultado
    loop_array3:
        LDR w0, [x15], 4
        LDR x1, =num
        BL itoa

        print num, x10
        print espacio, lenEspacio

        ADD x7, x7, 1
        CMP x9, x7
        BNE loop_array3

    print newline, lennewline
    print precionarEnter, lenPrecionarEnter
    read 0, filename, 50
    b menuS



// Función Quick Sort
quicksort2:
    // x0 = array [direccion de memoria]
    // x1 = inicio
    // x2 = fin

    // if (inicio >= fin)
    CMP x1, x2
    BGE quicksort_final3
    // endif
    LDR w3, [x0, x1, LSL 2]  // pivote -> w3 | pivote = array[inicio]

    // izq = x4, der = x5
    ADD x4, x1, 1   // izq = inicio + 1
    MOV x5, x2      // der = fin

    // while(izq <= der)
    quicksort_while_principal2:

        // while(izq <= fin && array[izq] < pivote)
        quicksort_while_interno_12:

            // primera condicion: izq <= fin
            CMP x4, x2
            BGT quicksort_while_interno_22
            // segunda condicion: array[izq] < pivote
            LDR w6, [x0, x4, LSL 2]    // array[izq]
            CMP w6, w3
            BLE quicksort_while_interno_22
            ADD x4, x4, 1   // izq++
            B quicksort_while_interno_12


        // while(der > inicio && array[der] >= pivote)
        quicksort_while_interno_22:
            // primera condicion: der > inicio
            CMP x5, x1
            BLE quicksort_intercambio2
            // segunda condicion: array[der] >= pivote
            LDR w6, [x0, x5, LSL 2]    // array[der]
            CMP w6, w3
            BGT quicksort_intercambio2
            SUB x5, x5, 1   // der--
            B quicksort_while_interno_22


        // if(izq < der)
        quicksort_intercambio2:

            // condicion: izq < der
            CMP x4, x5
            BGE quicksort_while_continuacion2
            // hacer intercambio
            LDR w6, [x0, x4, LSL 2]    // array[izq]
            LDR w7, [x0, x5, LSL 2]    // array[der]
            STR w7, [x0, x4, LSL 2]    // array[izq] = array[der]
            STR w6, [x0, x5, LSL 2]    // array[der] = array[izq]

        // condicion while principal: izq <= der
        quicksort_while_continuacion2:
            CMP x4, x5
            BLE quicksort_while_principal2
            
    // bloque condicionante: if(der > inicio)
    CMP x5, x1
    BLE quicksort_recursividad2

    // hacer intercambio
    LDR w6, [x0, x1, LSL 2]    // array[inicio]
    LDR w7, [x0, x5, LSL 2]    // array[der]

    STR w7, [x0, x1, LSL 2]    // array[inicio] = array[der]
    STR w6, [x0, x5, LSL 2]    // array[der] = array[inicio]

    quicksort_recursividad2:
        // PRIMERA RECURSIVIDAD
        // almacenar en la pila los registros  x1 = inicio x5 = der  x2 = fin
        STP x1, x2, [SP, #-16]!
        STR x5, [SP, #-16]!

        // actualizar parametro: fin = der - 1
        SUB x2, x5, 1
        
        // almacenar puntero del progrma en la pila
        STP x29, x30, [SP, #-16]!

        // primera llamada recursiva: quicksort(array, inicio, der - 1)
        BL quicksort2

        // recuperar puntero del programa de la pila
        LDP x29, x30, [SP], #16

        // recuperar registro  x1 = inicio x5 = der  x2 = fin
        LDR x5, [SP], 16
        LDP x1, x2, [SP], 16

        // SEGUNDA RECURSIVIDAD
        // almacenar en la pila los registros  x1 = inicio x5 = der  x2 = fin
        STP x1, x2, [SP, -16]!
        STR x5, [SP, -16]!

        // actualizar parametro: inicio = der + 1
        ADD x1, x5, 1
        
        // almacenar puntero del progrma en la pila
        STP x29, x30, [SP, -16]!

        // primera llamada recursiva: quicksort(array, inicio, der - 1)
        BL quicksort2

        // recuperar puntero del programa de la pila
        LDP x29, x30, [SP], 16

        // recuperar registros x1 = inicio x5 = der  x2 = fin
        LDR x5, [SP], 16
        LDP x1, x2, [SP], 16

    quicksort_final3:
        RET





quicksort_Pasos_inicio2_Desendente:
    MOV x11, 0                      // Inicializar contador
    bl print_array           // Llamar a la rutina para imprimir el arreglo
    //fin
    //cargamos los valores iniciales
    LDR x0, =array
    MOV x1, 0
    LDR x2, =count
    LDR x2, [x2] // length => cantidad de numeros leidos del csv
    SUB x2, x2, 1
    // almacenar puntero del progrma en la pila
    STP x29, x30, [SP, #-16]!

    bl quicksort_Pasos4
    // recuperar puntero del programa de la pila
    LDP x29, x30, [SP], #16

    print newline, lennewline
    print precionarEnter, lenPrecionarEnter
    read 0, filename, 50
    b menuS

    // Función Quick Sort
    quicksort_Pasos4:
        // x0 = array [direccion de memoria]
        // x1 = inicio
        // x2 = fin

        // if (inicio >= fin)
        CMP x1, x2
        BGE quicksort_final4
        // endif
        LDR w3, [x0, x1, LSL 2]  // pivote -> w3 | pivote = array[inicio]

        // izq = x4, der = x5
        ADD x4, x1, 1   // izq = inicio + 1
        MOV x5, x2      // der = fin

        // while(izq <= der)
        quicksort_while_principal14:

            // while(izq <= fin && array[izq] < pivote)
            quicksort_while_interno_14:

                // primera condicion: izq <= fin
                CMP x4, x2
                BGT quicksort_while_interno_24
                // segunda condicion: array[izq] < pivote
                LDR w6, [x0, x4, LSL 2]    // array[izq]
                CMP w6, w3
                BLE quicksort_while_interno_24
                ADD x4, x4, 1   // izq++
                B quicksort_while_interno_14


            // while(der > inicio && array[der] >= pivote)
            quicksort_while_interno_24:
                // primera condicion: der > inicio
                CMP x5, x1
                BLE quicksort_intercambio4
                // segunda condicion: array[der] >= pivote
                LDR w6, [x0, x5, LSL 2]    // array[der]
                CMP w6, w3
                BGT quicksort_intercambio4
                SUB x5, x5, 1   // der--
                B quicksort_while_interno_24


            // if(izq < der)
            quicksort_intercambio4:

                // condicion: izq < der
                CMP x4, x5
                BGE quicksort_while_continuacion4
                // hacer intercambio
                LDR w6, [x0, x4, LSL 2]    // array[izq]
                LDR w7, [x0, x5, LSL 2]    // array[der]
                STR w7, [x0, x4, LSL 2]    // array[izq] = array[der]
                STR w6, [x0, x5, LSL 2]    // array[der] = array[izq]

                STP x29, x30, [SP, #-16]!
                //Aca la imprecion del pivote
                bl print_pivote
                LDP x29, x30, [SP], #16

                STP x29, x30, [SP, #-16]!
                ADD x11, x11 , 1 //x11 ++
                bl print_array           // Llamar a la rutina para imprimir el arreglo
                LDP x29, x30, [SP], #16
            // condicion while principal: izq <= der
            quicksort_while_continuacion4:
                CMP x4, x5
                BLE quicksort_while_principal14
                
        // bloque condicionante: if(der > inicio)
        CMP x5, x1
        BLE quicksort_recursividad4

        // hacer intercambio
        LDR w6, [x0, x1, LSL 2]    // array[inicio]
        LDR w7, [x0, x5, LSL 2]    // array[der]

        STR w7, [x0, x1, LSL 2]    // array[inicio] = array[der]
        STR w6, [x0, x5, LSL 2]    // array[der] = array[inicio]

        STP x29, x30, [SP, #-16]!
        //Aca la imprecion del pivote
        bl print_pivote
        LDP x29, x30, [SP], #16

        STP x29, x30, [SP, #-16]!
        ADD x11, x11 , 1 //x11 ++
        bl print_array           // Llamar a la rutina para imprimir el arreglo
        LDP x29, x30, [SP], #16

        quicksort_recursividad4:
            // PRIMERA RECURSIVIDAD
            // STP x0, x1, [sp, #-16]! 
            // almacenar en la pila los registros  x1 = inicio x5 = der  x2 = fin
            STP x1, x2, [SP, #-16]!
            STR x5, [SP, #-16]!

            // actualizar parametro: fin = der - 1
            SUB x2, x5, 1
            
            // almacenar puntero del progrma en la pila
            STP x29, x30, [SP, #-16]!
            
            // primera llamada recursiva: quicksort(array, inicio, der - 1)
            BL quicksort_Pasos4

            // recuperar puntero del programa de la pila
            LDP x29, x30, [SP], #16

            // recuperar registro  x1 = inicio x5 = der  x2 = fin
            LDR x5, [SP], #16
            LDP x1, x2, [SP], #16

            // SEGUNDA RECURSIVIDAD
            // almacenar en la pila los registros  x1 = inicio x5 = der  x2 = fin
            STP x1, x2, [SP, #-16]!
            STR x5, [SP, #-16]!

            // actualizar parametro: inicio = der + 1
            ADD x1, x5, 1
            
            // almacenar puntero del progrma en la pila
            STP x29, x30, [SP, #-16]!
            
            // primera llamada recursiva: quicksort(array, inicio, der - 1)
            BL quicksort_Pasos4

            // recuperar puntero del programa de la pila
            LDP x29, x30, [SP], #16
            
            // recuperar registros x1 = inicio x5 = der  x2 = fin
            LDR x5, [SP], #16
            LDP x1, x2, [SP], #16

        quicksort_final4:
            ret



//***************************************** Fin del Quick Sort Decendete**************

copy_array:
    // Asumimos que array y array2 tienen el mismo tamaño (1024 bytes)
    LDR x0, =array      // Cargar la dirección de 'array' en x0
    LDR x1, =array2     // Cargar la dirección de 'array2' en x1
    MOV x2, 1024        // Tamaño del array (1024 bytes)

    copy_loop:
        LDRB w3, [x0], 1    // Cargar byte desde 'array' en w3 y avanzar x0
        STRB w3, [x1], 1    // Almacenar byte en 'array2' y avanzar x1
        SUBS x2, x2, 1      // Decrementar el contador de bytes
        BNE copy_loop       // Repetir hasta copiar todos los bytes

        // Fin de la rutina
        RET



copy_array2:
    // Asumimos que array y array2 tienen el mismo tamaño (1024 bytes)
    LDR x0, =array2      // Cargar la dirección de 'array2' en x0
    LDR x1, =array     // Cargar la dirección de 'array' en x1
    MOV x2, 1024        // Tamaño del array (1024 bytes)

    copy_loop2:
        LDRB w3, [x0], 1    // Cargar byte desde 'array2' en w3 y avanzar x0
        STRB w3, [x1], 1    // Almacenar byte en 'array' y avanzar x1
        SUBS x2, x2, 1      // Decrementar el contador de bytes
        BNE copy_loop2       // Repetir hasta copiar todos los bytes

        // Fin de la rutina
        RET


itoa:
    // params: x0 => number, x1 => buffer address
    MOV x10, 0  // contador de digitos a imprimir
    MOV x12, 0  // flag para indicar si hay signo menos
    MOV w2, 10000  // Base 10
    CMP w0, 0  // Numero a convertir
    BGT i_convertirAscii
    CBZ w0, i_zero

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
        NEG w0, w0

    i_convertirAscii:
        CBZ w2, i_endConversion
        UDIV w3, w0, w2
        CBZ w3, i_reduceBase

        MOV w5, w3
        ADD w5, w5, 48
        STRB w5, [x1], 1
        ADD x10, x10, 1

        MUL w3, w3, w2
        SUB w0, w0, w3

        CMP w2, 1
        BLE i_endConversion

        i_reduceBase:
            MOV w6, 10
            UDIV w2, w2, w6

            CBNZ w10, i_addZero
            B i_convertirAscii

        i_addZero:
            CBNZ w3, i_convertirAscii
            ADD x10, x10, 1
            MOV w5, 48
            STRB w5, [x1], 1
            B i_convertirAscii

    i_endConversion:
        ADD x10, x10, x12
        //print num, x10

    RET  //


