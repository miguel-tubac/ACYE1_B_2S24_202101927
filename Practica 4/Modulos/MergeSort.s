.global do_mergeSort

.extern array
.extern count


/*

El algoritmo de Merge Sort sigue una estrategia de "divide y vencerás", dividiendo el arreglo en mitades, ordenando cada mitad de 
manera recursiva, y luego combinando (o merge) los resultados ordenados.

 */
.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear

    menuPrincipal:
        .asciz "⇷⇷⇷⇷⇷⇷⇷ Menu Merge Sort ⇸⇸⇸⇸⇸⇸⇸\n"
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
        .asciz "\nResultado: [ "
        lenResultado = . - resulta

    pasosim:
        .asciz "\nPaso "
        lenpasosim = . -pasosim

    dospuntos:
        .asciz " : [ "
        lendospuntos = . - dospuntos
    
    conjInicial: 
        .asciz "\nConjunto inicial: [ "
        lenconjInicial = . - conjInicial

    corchetes:
        .asciz " ] , [ "
        lencorchetes = .-corchetes

    corchetFin:
        .asciz " ]"
        lencorchetFin = . - corchetFin


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
do_mergeSort:
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
            beq mergesort_pasos

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
            beq mergesort_pasos_Desendente
            
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
        ret                          // Regresar al punto donde se llamó



//***************************************** Inicio del Merge Sort Acendete**************

no_visualizar:
    ldr x0, =array                        // address number table
    mov x1,0                                       // first element
    LDR x2, =count
    LDR x2, [x2] // length => cantidad de numeros leidos del csv
    //SUB x2,x2,1                              // number of élements 
    bl mergeSort

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
    print corchetFin, lencorchetFin
    print newline, lennewline
    print precionarEnter, lenPrecionarEnter
    read 0, filename, 50
    b menuS


/*****  merge sort  **************/
/* x0 contiene la direccion del array */
/* x1 contiene el indice primero es decir 0 */
/* x2 contiene el numero de elementos n */
mergeSort:
    stp x3,lr,[sp,-16]!    // guarda los registros x3 y el link register (lr) en la pila
    stp x4,x5,[sp,-16]!    // guarda los registros x4 y x5 en la pila
    stp x6,x7,[sp,-16]!    // guarda los registros x6 y x7 en la pila
    cmp w2,2               // compara el número de elementos (w2) con 2
    
    blt merge_sort_end     // si hay menos de 2 elementos, salta al final
    lsr x4,x2,1            // calcula el número de elementos de cada subconjunto (n/2)
    add x5,x4,1            // incrementa el número de elementos del subconjunto por 1
    tst x2,#1              // verifica si el número de elementos es impar
    csel x4,x5,x4,ne       // si es impar, usa el valor incrementado; de lo contrario, usa n/2
    mov x5,x1              // guarda el primer índice (inicio) en x5
    mov x6,x2              // guarda el número total de elementos en x6
    mov x7,x4              // guarda el número de elementos de cada subconjunto en x7
    mov x2,x4              // actualiza el número de elementos a x4 para la llamada recursiva
    bl mergeSort           // llamada recursiva para ordenar el primer subconjunto

    mov x1,x7              // restaura el número de elementos de cada subconjunto
    mov x2,x6              // restaura el número total de elementos
    sub x2,x2,x1           // calcula el número de elementos en el segundo subconjunto
    mov x3,x5              // restaura el primer índice
    add x1,x1,x3           // suma 1 al primer índice
    bl mergeSort           // llama a mergeSort para ordenar el segundo subconjunto

    mov x1,x5              // restaura el primer índice
    mov x2,x7              // restaura el número de elementos del subconjunto
    add x2,x2,x1           // actualiza el número de elementos del segundo subconjunto
    mov x3,x6              // restaura el número total de elementos
    add x3,x3,x1           // suma el primer índice al total
    sub x3,x3,1            // ajusta para obtener el índice del último elemento
    bl merge               // llama a la función merge para combinar los subconjuntos

    merge_sort_end:
        ldp x6,x7,[sp],16      // restaura los registros x6 y x7 de la pila
        ldp x4,x5,[sp],16      // restaura los registros x4 y x5 de la pila
        ldp x3,lr,[sp],16      // restaura el registro x3 y el link register (lr) de la pila
        ret                     // retorna a la dirección almacenada en lr (x30)


/************** merge ****************/
/* x0 contiene la direccion del array */
/* x1 contiene el primer indice a iniciar */
/* x2 contiene el segundo indice a iniciar */
/* x3 contiene el último indice   */ 
merge:
    stp x1,lr,[sp,-16]!        // guarda los registros x1 y el link register (lr) en la pila
    stp x2,x3,[sp,-16]!        // guarda los registros x2 y x3 en la pila
    stp x4,x5,[sp,-16]!        // guarda los registros x4 y x5 en la pila
    stp x6,x7,[sp,-16]!        // guarda los registros x6 y x7 en la pila
    str x8,[sp,-16]!           // guarda el registro x8 en la pila
    mov x5,x2                  // inicializa x5 con el índice del segundo subconjunto (x2)

    first_section_loop:            // inicio del bucle para la primera sección
        ldr w6,[x0,x1,lsl 2]       // carga el valor del primer subconjunto en w6
        ldr w7,[x0,x5,lsl 2]       // carga el valor del segundo subconjunto en w7
        cmp w6,w7                  // compara los dos valores
        ble second_section_advance  // si el valor de w6 es menor o igual, avanza en la segunda sección
        str w7,[x0,x1,lsl 2]       // almacena el valor del segundo subconjunto en la posición del primer subconjunto
        add x8,x5,1                // incrementa el índice del segundo subconjunto
        cmp w8,w3                  // verifica si se alcanzó el final del segundo subconjunto
        ble insert_element          // si no se alcanzó el final, salta a insertar elemento
        str w6,[x0,x5,lsl 2]       // almacena el valor de w6 en la posición correspondiente del segundo subconjunto
        b second_section_advance     // salta a avanzar en la segunda sección

    insert_element:                // inicia el bucle para insertar el elemento en la segunda parte
        sub x4,x8,1                // ajusta el índice para la inserción
        ldr w7,[x0,x8,lsl 2]       // carga el siguiente valor del segundo subconjunto
        cmp w6,w7                  // compara el valor de w6 con el valor del segundo subconjunto
        bge store_value            // si w6 es mayor o igual, salta a almacenar el valor
        str w6,[x0,x4,lsl 2]       // almacena w6 en la posición correspondiente
        b second_section_advance    // salta a avanzar en la segunda sección

    store_value:
        str w7,[x0,x4,lsl 2]       // almacena el valor de w7 en la posición correspondiente
        add x8,x8,1                // incrementa el índice del segundo subconjunto
        cmp w8,w3                  // verifica si se alcanzó el final del segundo subconjunto
        ble insert_element          // si no se alcanzó el final, regresa a insertar elemento
        sub x8,x8,1                // ajusta el índice para la inserción final
        str w6,[x0,x8,lsl 2]       // almacena el valor de w6 en la posición correspondiente
        
    second_section_advance:
        add x1,x1,1                // incrementa el índice del primer subconjunto
        cmp w1,w2                  // verifica si se alcanzó el final del primer subconjunto
        blt first_section_loop      // si no se alcanzó el final, regresa al inicio del bucle

    merge_return:
        ldr x8,[sp],16             // restaura el registro x8 de la pila
        ldp x6,x7,[sp],16          // restaura los registros x6 y x7 de la pila
        ldp x4,x5,[sp],16          // restaura los registros x4 y x5 de la pila
        ldp x2,x3,[sp],16          // restaura los registros x2 y x3 de la pila
        ldp x1,lr,[sp],16          // restaura los registros x1 y el link register (lr) de la pila
        ret                        // retorna a la dirección almacenada en lr (x30)



mergesort_pasos:
    MOV x11, 0                      // Inicializar contador
    bl print_array           // Llamar a la rutina para imprimir el arreglo

    ldr x0, =array                        // address number table
    mov x1,0                                       // first element
    LDR x2, =count
    LDR x2, [x2] // length => cantidad de numeros leidos del csv
    
    stp x29, x30, [sp, #-16]!    // Guardar el frame pointer y link register
    bl mergeSort2
    ldp x29, x30, [sp], #16      // Restaurar el frame pointer y link register

    MOV x11, -2                      // Inicializar contador
    bl print_array           // Llamar a la rutina para imprimir el arreglo

    print newline, lennewline
    print precionarEnter, lenPrecionarEnter
    read 0, filename, 50
    b menuS


    /*****  merge sort  **************/
    /* x0 contiene la direccion del array */
    /* x1 contiene el indice primero es decir 0 */
    /* x2 contiene el numero de elementos n */
    mergeSort2:
        stp x3, lr, [sp, -16]!        // Guardar el registro x3 y el link register (lr) en la pila
        stp x4, x5, [sp, -16]!        // Guardar los registros x4 y x5 en la pila
        stp x6, x7, [sp, -16]!        // Guardar los registros x6 y x7 en la pila

        cmp w2, 2                     // Comparar el número de elementos (n) con 2
        blt merge_sort_end2           // Si n < 2, saltar al final de la función

        lsr x4, x2, 1                 // Calcular el número de elementos de cada subconjunto (n/2)
        add x5, x4, 1                  // Incrementar x5 en 1 (para manejar el caso impar)
        tst x2, #1                     // Verificar si n es impar
        csel x4, x5, x4, ne            // Si es impar, asignar x4 el valor de x5

        mov x5, x1                     // Guardar el primer índice (0) en x5
        mov x6, x2                     // Guardar el número total de elementos en x6
        mov x7, x4                     // Guardar el número de elementos de cada subconjunto en x7
        mov x2, x4                     // Mover el número de elementos de cada subconjunto a x2
        bl mergeSort2                  // Llamar recursivamente a mergeSort2 para el primer subconjunto

        mov x1, x7                     // Restaurar el número de elementos del subconjunto en x1
        mov x2, x6                     // Restaurar el número total de elementos en x2
        sub x2, x2, x1                 // Calcular el número de elementos restantes para el segundo subconjunto
        mov x3, x5                     // Restaurar el primer índice en x3
        add x1, x1, x3                 // Incrementar x1 para incluir el primer índice
        bl mergeSort2                  // Llamar recursivamente a mergeSort2 para el segundo subconjunto

        mov x1, x5                     // Restaurar el primer índice en x1
        mov x2, x7                     // Restaurar el número de elementos del subconjunto en x2
        add x2, x2, x1                 // Calcular el índice del último elemento
        mov x3, x6                     // Restaurar el número total de elementos en x3
        add x3, x3, x1                 // Ajustar el número total de elementos
        sub x3, x3, 1                  // Calcular el último índice
        bl merge2                      // Llamar a la función merge para fusionar los subconjuntos

        merge_sort_end2:
            ldp x6, x7, [sp], 16           // Restaurar los registros x6 y x7 de la pila
            ldp x4, x5, [sp], 16           // Restaurar los registros x4 y x5 de la pila
            ldp x3, lr, [sp], 16           // Restaurar el registro x3 y el link register (lr) de la pila
            ret                             // Retornar a la dirección almacenada en lr (link register)

    /************** merge ****************/
    /* x0 contiene la direccion del array */
    /* x1 contiene el primer indice a iniciar */
    /* x2 contiene el segundo indice a iniciar */
    /* x3 contiene el ultimo indice   */ 
    merge2:
        stp x1, lr, [sp, -16]!         // Guardar el registro x1 y el link register (lr) en la pila
        stp x2, x3, [sp, -16]!         // Guardar los registros x2 y x3 en la pila
        stp x4, x5, [sp, -16]!         // Guardar los registros x4 y x5 en la pila
        stp x6, x7, [sp, -16]!         // Guardar los registros x6 y x7 en la pila
        str x8, [sp, -16]!             // Guardar el registro x8 en la pila
        mov x5, x2                     // Inicializar el índice x5 con el segundo índice (x2)

        first_section_loop2:              // Inicio del bucle para la primera sección
            ldr w6, [x0, x1, lsl 2]       // Cargar el valor del primer índice (subconjunto 1)
            ldr w7, [x0, x5, lsl 2]       // Cargar el valor del segundo índice (subconjunto 2)
            cmp w6, w7                     // Comparar los valores de los dos subconjuntos
            ble second_section_advance2    // Si w6 <= w7, avanzar a la siguiente sección

            str w7, [x0, x1, lsl 2]       // Almacenar el valor del segundo índice en el primer índice
            add x8, x5, 1                  // Incrementar el índice del segundo subconjunto
            cmp w8, w3                     // Comparar si se alcanzó el final del segundo subconjunto
            ble insert_element2            // Si no se alcanzó el final, saltar a insertar el elemento
            str w6, [x0, x5, lsl 2]       // Almacenar el valor del primer índice en el segundo índice
            b second_section_advance2      // Volver al bucle principal

        insert_element2:                  // Bucle para insertar el elemento del primer subconjunto en el segundo
            sub x4, x8, 1                  // Ajustar el índice para insertar en la posición correcta
            ldr w7, [x0, x8, lsl 2]       // Cargar el valor del segundo índice
            cmp w6, w7                     // Comparar el valor a insertar con el segundo índice
            bge store_value2               // Si w6 >= w7, almacenar el valor
            str w6, [x0, x4, lsl 2]       // Almacenar el valor del primer índice
            b second_section_advance2      // Volver al bucle principal

        store_value2:                     // Almacenar el valor del segundo índice
            str w7, [x0, x4, lsl 2]       // Almacenar el valor del segundo índice
            add x8, x8, 1                  // Incrementar el índice del segundo subconjunto
            cmp w8, w3                     // Comparar si se alcanzó el final del segundo subconjunto
            ble insert_element2            // Si no se alcanzó el final, saltar a insertar el elemento
            sub x8, x8, 1                  // Ajustar el índice del segundo subconjunto
            str w6, [x0, x8, lsl 2]       // Almacenar el valor del primer índice en la última posición del segundo

        second_section_advance2:          // Avanzar al siguiente índice del primer subconjunto
            add x1, x1, 1                  // Incrementar el índice del primer subconjunto
            cmp w1, w2                     // Comparar si se alcanzó el final del primer subconjunto
            blt first_section_loop2        // Si no se alcanzó el final, continuar el bucle

            stp x29, x30, [sp, #-16]!      // Guardar el frame pointer (x29) y el link register (x30) en la pila
            ADD x11, x11, 1                // Incrementar x11 (puede ser contador de llamadas o similar)
            bl print_array                  // Llamar a la rutina para imprimir el arreglo
            LDP x29, x30, [SP], #16        // Restaurar el frame pointer y el link register

        merge_return2:
            ldr x8, [sp], 16               // Restaurar el registro x8 de la pila
            ldp x6, x7, [sp], 16           // Restaurar los registros x6 y x7 de la pila
            ldp x4, x5, [sp], 16           // Restaurar los registros x4 y x5 de la pila
            ldp x2, x3, [sp], 16           // Restaurar los registros x2 y x3 de la pila
            ldp x1, lr, [sp], 16           // Restaurar el registro x1 y el link register (lr) de la pila
            ret                             // Retornar a la dirección almacenada en lr (link register)





print_array:
    STP x29, x30, [sp, #-16]!      // Guardar Frame Pointer (x29) y Link Register (x30)
    MOV x29, sp                    // Actualizar el Frame Pointer al valor de sp
    STP x0, x1, [sp, #-16]!        // Guardar x0 y x1 en la pila
    STP x6, x7, [sp, #-16]!       // Guardar registros adicionales
    STP x2, x3, [sp, #-16]!        // Guardar x2 y x3 (usados para itoa)
    STP x4, x5, [sp, #-16]!        // Guardar x4 y x5 (si se usan en itoa o la rutina actual)
    str x8,[sp,-16]!

    LDR x14, =count                // Cargar el valor de count (número de elementos)
    LDR x14, [x14]                 // Leer cantidad de números leídos del CSV
    MOV x7, 0                      // Inicializar contador
    LDR x15, =array                // Cargar la dirección del array

    CMP x11, 0
    beq inciando
    CMP x11, -2
    beq finalizacion

    mov x12,2
    sdiv x13, x14, x12        // Dividimos x14 / 2 y almacenamos el resultado en x13
    and  x16, x14, 1        // Calculamos el residuo de x14 % 2 (AND con 1 nos da el último bit que es el residuo)
    cbnz x16, tiene_decimales  // Si x15 no es cero, la división tiene decimales
    b continundo              // Si x15 es cero, es un número entero

    tiene_decimales:
        // Código para manejar el caso de que sea decimal
        add x13,x13,1
        b continundo 

    continundo:
        print pasosim, lenpasosim
        MOV x0, x11
        LDR x1, =num1
        BL itoa                        // Llamada a itoa para convertir el número
        print num1, x10
        print dospuntos, lendospuntos
        b loop_array2

    inciando:
        mov x13,-1
        print conjInicial, lenconjInicial
        b loop_array2

    finalizacion:
        mov x13,-1
        print resulta, lenResultado

    loop_array2:
        LDR w0, [x15], 4               // Cargar siguiente valor del array (elemento de 32 bits)
        LDR x1, =num                   // Apuntar el buffer a la cadena "num"

        BL itoa                        // Llamada a itoa para convertir el número
        print num, x10
        print espacio, lenEspacio      // Imprimir espacio entre los números

        ADD x7, x7, 1                  // Incrementar el contador

        CMP x7, x13
        beq imprimir_corchete
        b continuacion

        imprimir_corchete:
            print corchetes, lencorchetes
            
        continuacion:
            CMP x14, x7                    // Comparar el contador con el número total
            BNE loop_array2                // Si no se ha terminado, repetir

    print corchetFin, lencorchetFin
    // Imprimir nueva línea
    print newline, lennewline

    ldr x8,[sp],16             // restaur 1 register
    LDP x4, x5, [sp], #16          // Restaurar x4 y x5
    LDP x2, x3, [sp], #16          // Restaurar x2 y x3
    LDP x6, x7, [sp], #16         // Restaurar x9 y x10
    LDP x0, x1, [sp], #16          // Restaurar x0 y x1
    LDP x29, x30, [sp], #16        // Restaurar Frame Pointer y Link Register

    ret                            // Retornar de la función




//***************************************** Fin del Merge Sort Acendete**************



//***************************************** Inicio del Merge Sort Decendente**************


no_visualizar2:
    ldr x0, =array                        // address number table
    mov x1,0                                       // first element
    LDR x2, =count
    LDR x2, [x2] // length => cantidad de numeros leidos del csv
    //SUB x2,x2,1                              // number of élements 
    STP x29, x30, [sp, #-16]!      // Guardar Frame Pointer (x29) y Link Register (x30)
    bl mergeSort3
    LDP x29, x30, [sp], #16        // Restaurar Frame Pointer y Link Register

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
    print corchetFin, lencorchetFin
    print newline, lennewline
    print precionarEnter, lenPrecionarEnter
    read 0, filename, 50
    b menuS


/*****  merge sort  **************/
/* x0 contiene la direccion del array */
/* x1 contiene el indice primero es decir 0 */
/* x2 contiene el numero de elementos n */
mergeSort3:
    stp x3,lr,[sp,-16]!    // guarda los registros x3 y el link register (lr) en la pila
    stp x4,x5,[sp,-16]!    // guarda los registros x4 y x5 en la pila
    stp x6,x7,[sp,-16]!    // guarda los registros x6 y x7 en la pila
    cmp w2,2               // compara el número de elementos (w2) con 2
    
    blt merge_sort_end3     // si hay menos de 2 elementos, salta al final
    lsr x4,x2,1            // calcula el número de elementos de cada subconjunto (n/2)
    add x5,x4,1            // incrementa el número de elementos del subconjunto por 1
    tst x2,#1              // verifica si el número de elementos es impar
    csel x4,x5,x4,ne       // si es impar, usa el valor incrementado; de lo contrario, usa n/2
    mov x5,x1              // guarda el primer índice (inicio) en x5
    mov x6,x2              // guarda el número total de elementos en x6
    mov x7,x4              // guarda el número de elementos de cada subconjunto en x7
    mov x2,x4              // actualiza el número de elementos a x4 para la llamada recursiva
    bl mergeSort3           // llamada recursiva para ordenar el primer subconjunto

    mov x1,x7              // restaura el número de elementos de cada subconjunto
    mov x2,x6              // restaura el número total de elementos
    sub x2,x2,x1           // calcula el número de elementos en el segundo subconjunto
    mov x3,x5              // restaura el primer índice
    add x1,x1,x3           // suma 1 al primer índice
    bl mergeSort3           // llama a mergeSort para ordenar el segundo subconjunto

    mov x1,x5              // restaura el primer índice
    mov x2,x7              // restaura el número de elementos del subconjunto
    add x2,x2,x1           // actualiza el número de elementos del segundo subconjunto
    mov x3,x6              // restaura el número total de elementos
    add x3,x3,x1           // suma el primer índice al total
    sub x3,x3,1            // ajusta para obtener el índice del último elemento
    bl merge3               // llama a la función merge para combinar los subconjuntos

    merge_sort_end3:
        ldp x6,x7,[sp],16      // restaura los registros x6 y x7 de la pila
        ldp x4,x5,[sp],16      // restaura los registros x4 y x5 de la pila
        ldp x3,lr,[sp],16      // restaura el registro x3 y el link register (lr) de la pila
        ret                     // retorna a la dirección almacenada en lr (x30)


/************** merge ****************/
/* x0 contiene la direccion del array */
/* x1 contiene el primer indice a iniciar */
/* x2 contiene el segundo indice a iniciar */
/* x3 contiene el último indice   */ 
merge3:
    stp x1,lr,[sp,-16]!        // guarda los registros x1 y el link register (lr) en la pila
    stp x2,x3,[sp,-16]!        // guarda los registros x2 y x3 en la pila
    stp x4,x5,[sp,-16]!        // guarda los registros x4 y x5 en la pila
    stp x6,x7,[sp,-16]!        // guarda los registros x6 y x7 en la pila
    str x8,[sp,-16]!           // guarda el registro x8 en la pila
    mov x5,x2                  // inicializa x5 con el índice del segundo subconjunto (x2)

    first_section_loop3:            // inicio del bucle para la primera sección
        ldr w6,[x0,x1,lsl 2]       // carga el valor del primer subconjunto en w6
        ldr w7,[x0,x5,lsl 2]       // carga el valor del segundo subconjunto en w7
        cmp w6,w7                  // compara los dos valores
        bge second_section_advance3  // si el valor de w6 es mayor o igual, avanza en la segunda sección
        str w7,[x0,x1,lsl 2]       // almacena el valor del segundo subconjunto en la posición del primer subconjunto
        add x8,x5,1                // incrementa el índice del segundo subconjunto
        cmp w8,w3                  // verifica si se alcanzó el final del segundo subconjunto
        ble insert_element3          // si no se alcanzó el final, salta a insertar elemento
        str w6,[x0,x5,lsl 2]       // almacena el valor de w6 en la posición correspondiente del segundo subconjunto
        b second_section_advance3     // salta a avanzar en la segunda sección

    insert_element3:                // inicia el bucle para insertar el elemento en la segunda parte
        sub x4,x8,1                // ajusta el índice para la inserción
        ldr w7,[x0,x8,lsl 2]       // carga el siguiente valor del segundo subconjunto
        cmp w6,w7                  // compara el valor de w6 con el valor del segundo subconjunto
        ble store_value3            // si w6 es menor o igual, salta a almacenar el valor
        str w6,[x0,x4,lsl 2]       // almacena w6 en la posición correspondiente
        b second_section_advance3    // salta a avanzar en la segunda sección

    store_value3:
        str w7,[x0,x4,lsl 2]       // almacena el valor de w7 en la posición correspondiente
        add x8,x8,1                // incrementa el índice del segundo subconjunto
        cmp w8,w3                  // verifica si se alcanzó el final del segundo subconjunto
        ble insert_element3          // si no se alcanzó el final, regresa a insertar elemento
        sub x8,x8,1                // ajusta el índice para la inserción final
        str w6,[x0,x8,lsl 2]       // almacena el valor de w6 en la posición correspondiente
        
    second_section_advance3:
        add x1,x1,1                // incrementa el índice del primer subconjunto
        cmp w1,w2                  // verifica si se alcanzó el final del primer subconjunto
        blt first_section_loop3      // si no se alcanzó el final, regresa al inicio del bucle

    merge_return3:
        ldr x8,[sp],16             // restaura el registro x8 de la pila
        ldp x6,x7,[sp],16          // restaura los registros x6 y x7 de la pila
        ldp x4,x5,[sp],16          // restaura los registros x4 y x5 de la pila
        ldp x2,x3,[sp],16          // restaura los registros x2 y x3 de la pila
        ldp x1,lr,[sp],16          // restaura los registros x1 y el link register (lr) de la pila
        ret                        // retorna a la dirección almacenada en lr (x30)







mergesort_pasos_Desendente:
    MOV x11, 0                      // Inicializar contador
    bl print_array           // Llamar a la rutina para imprimir el arreglo

    ldr x0, =array                        // address number table
    mov x1,0                                       // first element
    LDR x2, =count
    LDR x2, [x2] // length => cantidad de numeros leidos del csv
    
    stp x29, x30, [sp, #-16]!    // Guardar el frame pointer y link register
    bl mergeSort4
    ldp x29, x30, [sp], #16      // Restaurar el frame pointer y link register

    MOV x11, -2                      // Inicializar contador
    bl print_array           // Llamar a la rutina para imprimir el arreglo

    print newline, lennewline
    print precionarEnter, lenPrecionarEnter
    read 0, filename, 50
    b menuS


    /*****  merge sort  **************/
    /* x0 contiene la direccion del array */
    /* x1 contiene el indice primero es decir 0 */
    /* x2 contiene el numero de elementos n */
    mergeSort4:
        stp x3, lr, [sp, -16]!        // Guardar el registro x3 y el link register (lr) en la pila
        stp x4, x5, [sp, -16]!        // Guardar los registros x4 y x5 en la pila
        stp x6, x7, [sp, -16]!        // Guardar los registros x6 y x7 en la pila

        cmp w2, 2                     // Comparar el número de elementos (n) con 2
        blt merge_sort_end4           // Si n < 2, saltar al final de la función

        lsr x4, x2, 1                 // Calcular el número de elementos de cada subconjunto (n/2)
        add x5, x4, 1                  // Incrementar x5 en 1 (para manejar el caso impar)
        tst x2, #1                     // Verificar si n es impar
        csel x4, x5, x4, ne            // Si es impar, asignar x4 el valor de x5

        mov x5, x1                     // Guardar el primer índice (0) en x5
        mov x6, x2                     // Guardar el número total de elementos en x6
        mov x7, x4                     // Guardar el número de elementos de cada subconjunto en x7
        mov x2, x4                     // Mover el número de elementos de cada subconjunto a x2
        bl mergeSort4                  // Llamar recursivamente a mergeSort2 para el primer subconjunto

        mov x1, x7                     // Restaurar el número de elementos del subconjunto en x1
        mov x2, x6                     // Restaurar el número total de elementos en x2
        sub x2, x2, x1                 // Calcular el número de elementos restantes para el segundo subconjunto
        mov x3, x5                     // Restaurar el primer índice en x3
        add x1, x1, x3                 // Incrementar x1 para incluir el primer índice
        bl mergeSort4                  // Llamar recursivamente a mergeSort2 para el segundo subconjunto

        mov x1, x5                     // Restaurar el primer índice en x1
        mov x2, x7                     // Restaurar el número de elementos del subconjunto en x2
        add x2, x2, x1                 // Calcular el índice del último elemento
        mov x3, x6                     // Restaurar el número total de elementos en x3
        add x3, x3, x1                 // Ajustar el número total de elementos
        sub x3, x3, 1                  // Calcular el último índice
        bl merge4                      // Llamar a la función merge para fusionar los subconjuntos

        merge_sort_end4:
            ldp x6, x7, [sp], 16           // Restaurar los registros x6 y x7 de la pila
            ldp x4, x5, [sp], 16           // Restaurar los registros x4 y x5 de la pila
            ldp x3, lr, [sp], 16           // Restaurar el registro x3 y el link register (lr) de la pila
            ret                             // Retornar a la dirección almacenada en lr (link register)

    /************** merge ****************/
    /* x0 contiene la direccion del array */
    /* x1 contiene el primer indice a iniciar */
    /* x2 contiene el segundo indice a iniciar */
    /* x3 contiene el ultimo indice   */ 
    merge4:
        stp x1, lr, [sp, -16]!         // Guardar el registro x1 y el link register (lr) en la pila
        stp x2, x3, [sp, -16]!         // Guardar los registros x2 y x3 en la pila
        stp x4, x5, [sp, -16]!         // Guardar los registros x4 y x5 en la pila
        stp x6, x7, [sp, -16]!         // Guardar los registros x6 y x7 en la pila
        str x8, [sp, -16]!             // Guardar el registro x8 en la pila
        mov x5, x2                     // Inicializar el índice x5 con el segundo índice (x2)

        first_section_loop4:              // Inicio del bucle para la primera sección
            ldr w6, [x0, x1, lsl 2]       // Cargar el valor del primer índice (subconjunto 1)
            ldr w7, [x0, x5, lsl 2]       // Cargar el valor del segundo índice (subconjunto 2)
            cmp w6, w7                     // Comparar los valores de los dos subconjuntos
            bge second_section_advance4    // Si w6 <= w7, avanzar a la siguiente sección

            str w7, [x0, x1, lsl 2]       // Almacenar el valor del segundo índice en el primer índice
            add x8, x5, 1                  // Incrementar el índice del segundo subconjunto
            cmp w8, w3                     // Comparar si se alcanzó el final del segundo subconjunto
            ble insert_element4            // Si no se alcanzó el final, saltar a insertar el elemento
            str w6, [x0, x5, lsl 2]       // Almacenar el valor del primer índice en el segundo índice
            b second_section_advance4      // Volver al bucle principal

        insert_element4:                  // Bucle para insertar el elemento del primer subconjunto en el segundo
            sub x4, x8, 1                  // Ajustar el índice para insertar en la posición correcta
            ldr w7, [x0, x8, lsl 2]       // Cargar el valor del segundo índice
            cmp w6, w7                     // Comparar el valor a insertar con el segundo índice
            ble store_value4               // Si w6 >= w7, almacenar el valor
            str w6, [x0, x4, lsl 2]       // Almacenar el valor del primer índice
            b second_section_advance4      // Volver al bucle principal

        store_value4:                     // Almacenar el valor del segundo índice
            str w7, [x0, x4, lsl 2]       // Almacenar el valor del segundo índice
            add x8, x8, 1                  // Incrementar el índice del segundo subconjunto
            cmp w8, w3                     // Comparar si se alcanzó el final del segundo subconjunto
            ble insert_element4            // Si no se alcanzó el final, saltar a insertar el elemento
            sub x8, x8, 1                  // Ajustar el índice del segundo subconjunto
            str w6, [x0, x8, lsl 2]       // Almacenar el valor del primer índice en la última posición del segundo

        second_section_advance4:          // Avanzar al siguiente índice del primer subconjunto
            add x1, x1, 1                  // Incrementar el índice del primer subconjunto
            cmp w1, w2                     // Comparar si se alcanzó el final del primer subconjunto
            blt first_section_loop4        // Si no se alcanzó el final, continuar el bucle

            stp x29, x30, [sp, #-16]!      // Guardar el frame pointer (x29) y el link register (x30) en la pila
            ADD x11, x11, 1                // Incrementar x11 (puede ser contador de llamadas o similar)
            bl print_array                  // Llamar a la rutina para imprimir el arreglo
            LDP x29, x30, [SP], #16        // Restaurar el frame pointer y el link register

        merge_return4:
            ldr x8, [sp], 16               // Restaurar el registro x8 de la pila
            ldp x6, x7, [sp], 16           // Restaurar los registros x6 y x7 de la pila
            ldp x4, x5, [sp], 16           // Restaurar los registros x4 y x5 de la pila
            ldp x2, x3, [sp], 16           // Restaurar los registros x2 y x3 de la pila
            ldp x1, lr, [sp], 16           // Restaurar el registro x1 y el link register (lr) de la pila
            ret                             // Retornar a la dirección almacenada en lr (link register)


//***************************************** Fin del Merge Sort Decendente**************


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






















