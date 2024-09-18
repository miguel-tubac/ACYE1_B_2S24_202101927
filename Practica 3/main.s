.global _start
.extern do_sum  // Declaramos la función externa que está en sum.S

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
        .asciz "1. Suma\n"
        .asciz "2. Resta\n"
        .asciz "3. Multiplicacion\n"
        .asciz "4. Division\n"
        .asciz "5. Calculo Con Memoria\n"
        .asciz "6. Finalizar calculadora\n"
        lenMenuPrincipal = .- menuPrincipal

    msgOpcion:
        .asciz "Ingrese Una Opcion: "
        lenOpcion = .- msgOpcion

    sumaText:
        .asciz "Ingresando Suma\n"
        lenSumaText = . - sumaText

    restaText:
        .asciz "Ingresando Resta\n"
        lenRestaText = . - restaText

    multiplicacionText:
        .asciz "Ingresando Multiplicacion\n"
        lenMultiplicacionText = . - multiplicacionText

    divisionText:
        .asciz "Ingresando Division\n"
        lenDivisionText = . - divisionText

    operacionesText:
        .asciz "Ingresando Operaciones\n"
        lenOperacionesText = . - operacionesText

    erronea:
        .asciz "\nOpción no válida, intenta de nuevo..."
        lenErronea = . - erronea

.bss
    opcion:
        .space 5   // => El 5 indica cuantos BYTES se reservaran para la variable opcion

.macro print texto, cantidad
    MOV x0, 1
    LDR x1, =\texto
    LDR x2, =\cantidad
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
        beq suma

        cmp w10, 50
        beq resta

        cmp w10, 51
        beq multiplicacion

        cmp w10, 52
        beq division

        cmp w10, 53
        beq operacion_memoria

        cmp w10, 54
        beq end

        b invalido

        invalido:
            print erronea, lenErronea
            B cont

        suma:
            print sumaText, lenSumaText
            // Pedir numeros de entrada
            // replicar el funcionamiendo de atoi(ASCII TO INTEGER)[Funcion de C]
            // realizar operacion
            // replicar el funcionamiento de itoa(INTEGER TO ASCII)[Funcion de C]
            bl do_sum               // Llamar a la función do_sum (en sum.S)
            B cont

        resta:
            print restaText, lenRestaText
            B cont

        multiplicacion:
            print multiplicacionText, lenMultiplicacionText
            B cont

        division:
            print divisionText, lenDivisionText
            B cont
        
        operacion_memoria:
            print operacionesText, lenOperacionesText
            B cont

        cont:
            input
            B menu

    end:
        MOV x0, 0   // Codigo de error de la aplicacion -> 0: no hay error
        MOV x8, 93  // Codigo de la llamada al sistema
        SVC 0       // Ejecutar la llamada al sistema





