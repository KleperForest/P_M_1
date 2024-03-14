//*********************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programación de Microcontroladores
// Autor: Alan Gomez
// Proyecto: P_1_M.asm
// Descripción: Proyecto 1 de Programación de Microcontroladores. 
//				Versión 11.5.2 
// Hardware: ATmega328p
// Created: 3/06/2024 1:50:47 AM
//********************************************************************* 

//--------------------------------------------------------------------
// Configuración
//--------------------------------------------------------------------

.include "M328PDEF.inc"
 // R0-R15 Cargar y ciertas operaciones
 // R16-R29 Todo terreno
.def MU = R15; Minutos Unidad
.def MD = R14; Minutos Decena
.def HU = R13; Hora Unidad
.def HD = R12; Hora Decena
.def T6 = R11; Transistor 6
.def T5 = R10; Transistor 5
.def T1 = R9; Transistor 1	
.def T2 = R8; Transistor 2
.def T3 = R7; Transistor 3
.def T4 = R6; Transistor 4

.def T3_4 = R0; Transistor 3 en ALARMA
.def T4_4 = R1; Transistor 3 en ALARMA
.def T5_4 = R2; Transistor 3 en ALARMA
.def T6_4 = R3; Transistor 3 en ALARMA

.def T3_3 = R21; Transistor 3 
.def T4_3 = R22; Transistor 3 
.def T5_3 = R23; Transistor 3 
.def T6_3 = R24; Transistor 3 


.def HM_master = R27; Cargador de Numero en Display

.cseg; Comensamos con el segmento de Codigo. 
.ORG 0X00
	JMP SETUP
.ORG 0X0020
	JMP ISR_TIMER0_OVF

//*********************************************************************
// Stack Pointer
//*********************************************************************
LDI R16, LOW(RAMEND)// Ultima direccion de la memorio RAM 16bits
OUT SPL, R16 // Se colocara en el registro SPL
LDI R17, HIGH(RAMEND)// Seleccionamos la parte alta 
OUT SPH, R17 //Se colocara en el registro SPH
//*********************************************************************
//TABLA PARA DISPLAY 
//*********************************************************************
TABLA7U: .DB 0x7D,0x48,0x3E,0x6E,0x4B,0x67,0x77,0x4C,0x7F,0x4F
TABLA7D: .DB 0x7D,0x48,0x3E,0x6E,0x4B,0x67,0x7D
TABLA7Uh: .DB 0x7D,0x48,0x3E,0x6E,0x4B,0x67,0x77,0x4C,0x7F,0x4F
TABLA7Dh: .DB 0x7D,0x48,0x3E
// No es necesario tener 4 tablas la primera es suficiente
//Pero esto me ayudó a visualizar mejor como se realizaban los 
// cambios
//*********************************************************************

//*********************************************************************
//BODY
//*********************************************************************

SETUP:
	//Botones 
	SBI PORTC, PC1; Habilitando PULL-UP en PC1
	CBI DDRC, PC1; Habilitando PC1 como entrada
	SBI PORTC, PC2; Habilitando PULL-UP en PC2
	CBI DDRC, PC2; Habilitando PC2 como entrada
	SBI PORTC, PC3; Habilitando PULL-UP en PC3
	CBI DDRC, PC3; Habilitando PC3 como entrada
	SBI PORTC, PC4; Habilitando PULL-UP en PC4
	CBI DDRC, PC4; Habilitando PC4 como entrada
	SBI PORTC, PC5; Habilitando PULL-UP en PC5
	CBI DDRC, PC5; Habilitando PC5 como entrada

	//DISPLAY
	SBI DDRD, PD0; Hablitando PD0 como salida
	CBI PORTD, PD0; Apagar el bit PD0 
	SBI DDRD, PD1; Hablitando PD1 como salida
	CBI PORTD, PD1; Apagar el bit PD1 
	SBI DDRD, PD2; Hablitando PD2 como salida
	CBI PORTD, PD2; Apagar el bit PD2 
	SBI DDRD, PD3; Hablitando PD3 como salida
	CBI PORTD, PD3; Apagar el bit PD3 
	SBI DDRD, PD4; Hablitando PD4 como salida
	CBI PORTD, PD4; Apagar el bit PD4 
	SBI DDRD, PD5; Hablitando PD5 como salida
	CBI PORTD, PD5; Apagar el bit PD5 
	SBI DDRD, PD6; Hablitando PD6 como salida
	CBI PORTD, PD6; Apagar el bit PD6 

	//LEDs INTERMEDIOS
	SBI DDRD, PD7; Hablitando PD7 como salida
	CBI PORTD, PD7; Apagar el bit PD7 

	//LED MODO
	;RED
	SBI DDRC, PC0; Hablitando PC0 como salida
	CBI PORTC, PC0; Apagar el bit PC0 
	;GREEN
	SBI DDRB, PB5; Hablitando PB5 como salida
	CBI PORTB, PB5; Apagar el bit PB5 

	//BUZZER
	SBI DDRD, PB4; Hablitando PB4 como salida
	CBI PORTD, PB4; Apagar el bit PB4 

	//TRANSISTORES
	SBI DDRD, PB0; Hablitando PB0 como salida
	CBI PORTD, PB0; Apagar el bit PB0 
	SBI DDRD, PB1; Hablitando PB1 como salida
	CBI PORTD, PB1; Apagar el bit PB1 
	SBI DDRD, PB2; Hablitando PB2 como salida
	CBI PORTD, PB2; Apagar el bit PB2 
	SBI DDRD, PB3; Hablitando PB3 como salida
	CBI PORTD, PB3; Apagar el bit PB3 

	CLR T1	  // Limpiar registros de tiempo
	CLR T2
	CLR T3
	CLR T4
	CLR T5
	CLR T6
	LDI T3_3, 0
	LDI T4_3, 0
	LDI T5_3, 0
	LDI T6_3, 0
	LDI R16, 9
	MOV T3_4, R16
	LDI R16, 5
	MOV T4_4, R16
	LDI R16, 9
	MOV T5_4, R16
	LDI R16, 2
	MOV T6_4, R16

	

	CALL Init_T0
	SEI

// Estado inicial
S0:
	//Botones
	SBIS PINC, PC1// SALTA SI PC5 ES 1
	RJMP RETROpc1_S0// CAMBIO DE MODO

	//LED modo
	LDI R16, 0b0000_0001	// Green
	OUT PORTC, R16
	LDI R16, 0b0000_0000	// Red
	OUT PORTB, R16

	LDI R16, 0b1000_0000   //LEDs Intermedio
	OUT PORTD, R16

	// Displays
	MOV HM_master,T1   //Cargar posición de Unidad Segundos
	// Los T se deben cargar a HM_master ya que estos  
	// son de R0 a R15; no se puede utilar instrucciones 
	// como CPI, el cual utilizamos para comparar y saber
	// si el contador ya llego, como ejemplo, a 10 seg. 

	MOV HM_master,T2   //Cargar posición de Decena Segundos
	// Como tal es innecesario cargar en este apartado T1 y T2
	// ya que no tenemos displays para segundos
	// pero lo deje como indicador, cuando estaba realizando el código,
	// y que fuera más visual cuando se simulara en 
	// Microchip Studio

	MOV HM_master,T3  //Cargar posición de Unidad Minutos

	LDI R16, 0b0000_0001
	OUT PORTB, R16
	LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
	LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
	ADD ZL, HM_master
	LPM MU, Z
	OUT PORTD, MU// Mostrar en display
	

	CLR R16	// Wait-Esperar que se muestre valor mini-loop
	WAIT3:
		 INC R16
		 CPI R16,255
		 BRNE WAIT3

	MOV HM_master,T4   //Cargar posición de Decena de Minutos

	LDI R16, 0b0000_0010
	OUT PORTB, R16
	LDI ZH, HIGH(TABLA7D <<1); BIT MAS SIGNIFICATIVO
	LDI ZL, LOW(TABLA7D<<1); BIT MENOS SIGNIFICATIVO
	ADD ZL, HM_master
	LPM MD, Z
	OUT PORTD, MD// Mostrar en display


	CLR R16	 // Wait-Esperar que se muestre valor mini-loop
	WAIT4:
		 INC R16
		 CPI R16,255
		 BRNE WAIT4

	MOV HM_master,T5	//Cargar posición de Unidad de Horas

	LDI R16, 0b0000_0100
	OUT PORTB, R16
	LDI ZH, HIGH(TABLA7Uh <<1); BIT MAS SIGNIFICATIVO
	LDI ZL, LOW(TABLA7Uh<<1); BIT MENOS SIGNIFICATIVO
	ADD ZL, HM_master
	LPM HU, Z
	OUT PORTD, HU// Mostrar en display
	

	CLR R16	// Wait-Esperar que se muestre valor mini-loop
	WAIT5:
		 INC R16
		 CPI R16,255
		 BRNE WAIT5

	MOV HM_master,T6  //Cargar posición de Decena de Horas

	LDI R16, 0b0000_1000
	OUT PORTB, R16
	LDI ZH, HIGH(TABLA7Dh <<1); BIT MAS SIGNIFICATIVO
	LDI ZL, LOW(TABLA7Dh<<1); BIT MENOS SIGNIFICATIVO
	ADD ZL, HM_master
	LPM HD, Z
	OUT PORTD, HD// Mostrar en display


	CLR R16	 // Wait-Esperar que se muestre valor mini-loop
	WAIT6:
		 INC R16
		 CPI R16,255
		 BRNE WAIT6
	////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////
	// LED INTERMEDIO ENCENDIDO 500ms
	CPI R26, 50 // Conteo LOOP DE 500ms mostrando valores 
	BRNE S0
	CLR R26

	SBIS PINC, PC1// SALTA SI PC5 ES 1
	RJMP RETROpc1_S0// CAMBIO DE MODO
	////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////
	S0_S:// LED INTERMEDIO APAGADO 500ms
	// Es una copia exacta del apartado de arriba 
	// solo que en esta ocasión el Led intermedio 
	// estará apagado  tiempo de S0 y S0_S dan en total 1 segundo
	   	//LED modo
		LDI R16, 0b0000_0001   // Green
		OUT PORTC, R16
		LDI R16, 0b0000_0000  // RED
		OUT PORTB, R16

		LDI R16, 0b0000_0000	 // Intermedio 
		OUT PORTD, R16

		// Displays
		MOV HM_master,T1   //Cargar posición de Unidad Segundos

		MOV HM_master,T2   //Cargar posición de Decena Segundos
		// Como tal es innecesario cargar en este apartado T1 y T2
		// ya que no tenemos displays para segundos
		// pero lo deje como indicador, cuando estaba realizando el código,
		// y que fuera más visual cuando se simulara en 
		// Microchip Studio

		MOV HM_master,T3  //Cargar posición de Unidad Minutos

		LDI R16, 0b0000_0001
		OUT PORTB, R16
		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, HM_master
		LPM MU, Z
		OUT PORTD, MU// Mostrar en display
	

		CLR R16	// Wait-Esperar que se muestre valor mini-loop
		WAIT3_2:
			 INC R16
			 CPI R16,255
			 BRNE WAIT3_2

		MOV HM_master,T4   //Cargar posición de Decena de Minutos

		LDI R16, 0b0000_0010
		OUT PORTB, R16
		LDI ZH, HIGH(TABLA7D <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7D<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, HM_master
		LPM MD, Z
		OUT PORTD, MD// Mostrar en display


		CLR R16	 // Wait-Esperar que se muestre valor mini-loop
		WAIT4_2:
			 INC R16
			 CPI R16,255
			 BRNE WAIT4_2

		MOV HM_master,T5	//Cargar posición de Unidad de Horas

		LDI R16, 0b0000_0100
		OUT PORTB, R16
		LDI ZH, HIGH(TABLA7Uh <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7Uh<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, HM_master
		LPM HU, Z
		OUT PORTD, HU// Mostrar en display
	

		CLR R16	// Wait-Esperar que se muestre valor mini-loop
		WAIT5_2:
			 INC R16
			 CPI R16,255
			 BRNE WAIT5_2

		MOV HM_master,T6  //Cargar posición de Decena de Horas

		LDI R16, 0b0000_1000
		OUT PORTB, R16
		LDI ZH, HIGH(TABLA7Dh <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7Dh<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, HM_master
		LPM HD, Z
		OUT PORTD, HD// Mostrar en display


		CLR R16	 // Wait-Esperar que se muestre valor mini-loop
		WAIT6_2:
			 INC R16
			 CPI R16,255
			 BRNE WAIT6_2

		CPI R26, 50 // Conteo LOOP DE 500ms total 1s 
		BRNE S0_S
	CLR R26

	SBIS PINC, PC1// SALTA SI PC5 ES 1
	RJMP RETROpc1_S0// CAMBIO DE MODO
	////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////
	//Time
	INC T1; Valor a mostrar INCREMENTA

	MOV HM_master,T1   //Overflow Unidad Segundos
	CPI HM_master, 10
	BRCC over_nine_su

	MOV HM_master,T2	// Overflow Decena Segundos
	CPI HM_master, 6
	BRCC over_nine_sd

	MOV HM_master,T3   //Overflow Unidad Minutos
	CPI HM_master, 10
	BRCC over_nine_mu

	MOV HM_master,T4   // Overflow Decena Minutos
	CPI HM_master, 6
	BRCC over_nine_md

	MOV HM_master,T5   //Overflow Unidad Horas
	CPI HM_master, 10
	BRCC over_nine_hu

	MOV HM_master,T6   // Overflow Decena Horas
	CPI HM_master, 3
	BRCC over_nine_hd

	MOV HM_master,T6   // Overflow 24 Horas
	LDI R17, 2		  // Verificar que en Decenas de horas se 2
	CPSE HM_master, R17	// Si sí verificar valor en Unidad de Horas
	RJMP S0

	MOV HM_master, T5  // Si unidad de horas es mayor a 4 
	CPI HM_master, 4   // SET hora 00:00:00
	BRCC over_nine_hd
	RJMP S0



over_nine_su:  //Modulo de suma de decada seg y reseteo de unidad seg
	CLR T1
	INC T2
	RJMP S0

over_nine_sd:  //Modulo de suma de unidad min y reseteo de decada seg
	CLR T2
	INC T3
	RJMP S0

over_nine_mu:	//Modulo de suma de decada min y reseteo de unidad min
	CLR T3
	CLR MU
	INC T4
	RJMP S0

over_nine_md:  //Modulo de suma de unidad h y reseteo de decada min
	CLR T4
	CLR MD
	INC T5
	RJMP S0

over_nine_hu:  //Modulo de suma de decada h y reseteo de unidad h
	CLR T5
	CLR HU 
	INC	T6
	RJMP S0

over_nine_hd:  //Modulo de suma de decada h y reseteo de unidad h
	CLR T5
	CLR T6
	CLR T4
	CLR T3
	CLR T2
	CLR T1
	CLR HD
	RJMP S0

/////////////////////////////////////////////////////////////////////////
// Estado de C.T.
S1:	// Clear T1 y T2
	// Aumentar o Disminuir T3, T4, T5, T6 e indidar V4
	CLR T1
	CLR T2

	//LED modo
	LDI R16, 0b0000_0000   //GREEN
	OUT PORTC, R16
	LDI R16, 0b0010_0000 // RED
	OUT PORTB, R16

	LDI R16, 0b0000_0000	 // INTERMEDIO
	OUT PORTD, R16


	//BOTONES
	//Modo
	SBIS PINC, PC1// SALTA SI PC1 ES 1
	RJMP RETROpc1_S1// CAMBIO DE MODO
	//SET
	SBIS PINC, PC2// SALTA SI PC2 ES 1
	RJMP RETROpc2_S1// CAMBIO DE MODO
	//RIGHT
	SBIS PINC, PC3// SALTA SI PC3 ES 1
	RJMP SEMU
	//RJMP RETROpc3_S1// CAMBIO DE MODO
		
	RJMP S1
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	SEMU:
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEMU
		RJMP EMU

	EMU:  //   INC|DEC T3
		//SET
		SBIS PINC, PC2// SALTA SI PC2 ES 1
		RJMP RETROpc2_S1// CAMBIO DE MODO
		//LEFT
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEMD
		//RJMP RETROpc3_S1// CAMBIO DE MODO
		//DEC
		SBIS PINC, PC4// SALTA SI PC4 ES 1
		RJMP DECEMU
		//RJMP RETROpc4_S1// CAMBIO DE MODO
		//INC
		SBIS PINC, PC5// SALTA SI PC5 ES 1
		RJMP INCEMU
		//RJMP RETROpc5_S1// CAMBIO DE MODO

		LDI R16, 0b0000_0001  // Transistor de US
		OUT PORTB, R16

		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, T3
		LPM MU, Z
		OUT PORTD, MU// Mostrar en display

		RJMP EMU


	DECEMU:	
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,0 // Cargar valor de comparacion
		CPSE R16, T3  // Comparar si es 0
		RJMP DECEMU_2 // Si si ir a decrementar

		LDI R16, 9	 // Si no cargar 9
		MOV T3, R16	 // cargar T6 con 9
	
		WAIT_DECEMU:  // Esperar de dejar de presionar
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEMU
			RJMP EMU
		

	DECEMU_2:
		CLR R16	// Limpiar registro	 arbitrario
		MOV R16, T3	// Cargar T6 en registro
		DEC R16	   // Decrementar registro
		MOV T3, R16	 //Cargar resultado
		WAIT_DECEMU_1:	// cambio de boton
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEMU_1
			RJMP EMU

	INCEMU:
		CLR R16	 // Limprar registro  arbitrario
		LDI R16, 9 // cargar 9  
		CPSE R16, T3	// verificar que no sea 9
		RJMP INCEMU_2 // si si ir a incrementar

		LDI R16, 0	 // si no cargar 0
		MOV T3, R16	// cargar 0
	
		WAIT_INCEMU:// esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEMU
			RJMP EMU
	
	INCEMU_2:
		CLR R16	// limpiar registro arbitrario
		MOV R16, T3	// cargar t6
		INC R16	   // incrementar
		MOV T3, R16 // cargar valor a t6

		WAIT_INCEMU_1: // esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEMU_1
			RJMP EMU	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	SEMD:
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEMD
		RJMP EMD

	EMD:  //   INC|DEC T4
	//SET
		SBIS PINC, PC2// SALTA SI PC2 ES 1
		RJMP RETROpc2_S1// CAMBIO DE MODO
		//RIGHT
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEHU
		//RJMP RETROpc3_S1// CAMBIO DE MODO
		//DEC
		SBIS PINC, PC4// SALTA SI PC4 ES 1
		RJMP DECEMD
		//RJMP RETROpc4_S1// CAMBIO DE MODO
		//INC
		SBIS PINC, PC5// SALTA SI PC5 ES 1
		RJMP INCEMD
		//RJMP RETROpc5_S1// CAMBIO DE MODO

		LDI R16, 0b0000_0010   // transistor 2
		OUT PORTB, R16

		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, T4
		LPM MD, Z
		OUT PORTD, MD// Mostrar en display

		RJMP EMD

	DECEMD:	
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,0 // Cargar valor de comparacion
		CPSE R16, T4  // Comparar si es 0
		RJMP DECEMD_2 // Si si ir a decrementar

		LDI R16, 5	 // Si no cargar 5
		MOV T4, R16	 // cargar T6 con 5
	
		WAIT_DECEMD:  // Esperar de dejar de presionar
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEMD
			RJMP EMD
		

	DECEMD_2:
		CLR R16	// Limpiar registro	 arbitrario
		MOV R16, T4	// Cargar T6 en registro
		DEC R16	   // Decrementar registro
		MOV T4, R16	 //Cargar resultado
		WAIT_DECEMD_1:	// cambio de boton
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEMD_1
			RJMP EMD

	INCEMD:
		CLR R16	 // Limprar registro  arbitrario
		LDI R16, 5 // cargar 5
		CPSE R16, T4	// verificar que no sea 5
		RJMP INCEMD_2 // si si ir a incrementar

		LDI R16, 0	 // si no cargar 0
		MOV T4, R16	// cargar 0
	
		WAIT_INCEMD:// esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEMD
			RJMP EMD
	
	INCEMD_2:
		CLR R16	// limpiar registro arbitrario
		MOV R16, T4	// cargar t6
		INC R16	   // incrementar
		MOV T4, R16 // cargar valor a t6

		WAIT_INCEMD_1: // esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEMD_1
			RJMP EMD

	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	SEHU:
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEHU
		RJMP EHU

	EHU:   //   INC|DEC T5	- V4
	   //SET
		SBIS PINC, PC2// SALTA SI PC2 ES 1
		RJMP RETROpc2_S1// CAMBIO DE MODO
		//RIGHT
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEHD
		//RJMP RETROpc3_S1// CAMBIO DE MODO
		//DEC
		SBIS PINC, PC4// SALTA SI PC4 ES 1
		RJMP DECEHU
		//RJMP RETROpc4_S1// CAMBIO DE MODO
		//INC
		SBIS PINC, PC5// SALTA SI PC5 ES 1
		RJMP INCEHU
		//RJMP RETROpc5_S1// CAMBIO DE MODO

		LDI R16, 0b0000_0100 // transistor 3
		OUT PORTB, R16

		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, T5
		LPM HU, Z
		OUT PORTD, HU// Mostrar en display

		RJMP EHU

	DECEHU:	
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,0 // Cargar valor de comparacion
		CPSE R16, T5  // Comparar si es 0
		RJMP DECEHU_2 // Si si ir a decrementar

		LDI R16, 9	 // Si no cargar 9
		MOV T5, R16	 // cargar T6 con 9
	
		WAIT_DECEHU:  // Esperar de dejar de presionar
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEHU
			RJMP EHU
		

	DECEHU_2:
		CLR R16	// Limpiar registro	 arbitrario
		MOV R16, T5	// Cargar T6 en registro
		DEC R16	   // Decrementar registro
		MOV T5, R16	 //Cargar resultado
		WAIT_DECEHU_1:	// cambio de boton
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEHU_1
			RJMP EHU

	INCEHU:
		CLR R16	 // Limprar registro  arbitrario
		LDI R16, 9 // cargar 9  
		CPSE R16, T5	// verificar que no sea 9
		RJMP INCEHU_2 // si si ir a incrementar

		LDI R16, 0	 // si no cargar 0
		MOV T5, R16	// cargar 0
	
		WAIT_INCEHU:// esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEHU
			RJMP EHU
	
	INCEHU_2:
		CLR R16	// limpiar registro arbitrario
		MOV R16, T5	// cargar t6
		INC R16	   // incrementar
		MOV T5, R16 // cargar valor a t6

		WAIT_INCEHU_1: // esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEHU_1
			RJMP EHU

	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	SEHD:
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEHD
		RJMP EHD
	EHD:	 //   INC|DEC T6 - V4
		//SET
		SBIS PINC, PC2// SALTA SI PC2 ES 1
		RJMP RETROpc2_S1// CAMBIO DE MODO
		//RIGHT
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEMU
		//RJMP RETROpc3_S1// CAMBIO DE MODO
		//DEC
		SBIS PINC, PC4// SALTA SI PC4 ES 1
		RJMP DECEHD
		//RJMP RETROpc4_S1// CAMBIO DE MODO
		//INC
		SBIS PINC, PC5// SALTA SI PC5 ES 1
		RJMP INCEHD
		//RJMP RETROpc5_S1// CAMBIO DE MODO

		LDI R16, 0b0000_1000 // Activar transistor de U o D
		OUT PORTB, R16

		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, T6
		LPM HD, Z
		OUT PORTD, HD// Mostrar en display

		RJMP EHD

	DECEHD:	
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,0 // Cargar valor de comparacion
		CPSE R16, T6  // Comparar si es 0
		RJMP DECEHD_2 // Si si ir a decrementar

		LDI R16, 2	 // Si no cargar 2
		MOV T6, R16	 // cargar T6 con 2
	
		WAIT_DECEHD:  // Esperar de dejar de presionar
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEHD
			RJMP EHD
		

	DECEHD_2:
		CLR R16	// Limpiar registro	 arbitrario
		MOV R16, T6	// Cargar T6 en registro
		DEC R16	   // Decrementar registro
		MOV T6, R16	 //Cargar resultado
		WAIT_DECEHD_1:	// cambio de boton
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEHD_1
			RJMP EHD

	INCEHD:
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,2 // cargar 2  
		CPSE R16, T6	// verificar que no sea 2
		RJMP INCEHD_2 // si si ir a incrementar

		LDI R16, 0	 // si no cargar 0
		MOV T6, R16	// cargar 0
	
		WAIT_INCEHD:// esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEHD
			RJMP EHD
	
	INCEHD_2:
		CLR R16	// limpiar registro arbitrario
		MOV R16, T6	// cargar t6
		INC R16	   // incrementar
		MOV T6, R16 // cargar valor a t6

		WAIT_INCEHD_1: // esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEHD_1
			RJMP EHD
		


////////////////////////////////////////////////////////////////////////
// Estado de Fecha
S2:
	//Botones
	SBIS PINC, PC1// SALTA SI PC1 ES 1
	RJMP RETROpc1_S2// CAMBIO DE MODO


	//LED modo
	LDI R16, 0b1000_0000  // led intermedio
	OUT PORTD, R16
	////////////////////////////////////
	MOV HM_master,T3_3  //Cargar posición de Unidad Minutos

	LDI R16, 0b0000_0001//ON transistor 1 pb0 - UMDis
	OUT PORTB, R16
	LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
	LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
	ADD ZL, HM_master
	LPM MU, Z
	OUT PORTD, MU// Mostrar en display
	
	CLR R16	// Wait-Esperar que se muestre valor mini-loop
	WAIT3_3:
		 INC R16
		 CPI R16,255
		 BRNE WAIT3_3

	MOV HM_master,T4_3   //Cargar posición de Decena de Minutos

	LDI R16, 0b0000_0010
	OUT PORTB, R16
	LDI ZH, HIGH(TABLA7D <<1); BIT MAS SIGNIFICATIVO
	LDI ZL, LOW(TABLA7D<<1); BIT MENOS SIGNIFICATIVO
	ADD ZL, HM_master
	LPM MD, Z
	OUT PORTD, MD// Mostrar en display


	CLR R16	 // Wait-Esperar que se muestre valor mini-loop
	WAIT4_3:
		 INC R16
		 CPI R16,255
		 BRNE WAIT4_3

	MOV HM_master,T5_3	//Cargar posición de Unidad de Horas

	LDI R16, 0b0000_0100
	OUT PORTB, R16
	LDI ZH, HIGH(TABLA7Uh <<1); BIT MAS SIGNIFICATIVO
	LDI ZL, LOW(TABLA7Uh<<1); BIT MENOS SIGNIFICATIVO
	ADD ZL, HM_master
	LPM HU, Z
	OUT PORTD, HU// Mostrar en display
	

	CLR R16	// Wait-Esperar que se muestre valor mini-loop
	WAIT5_3:
		 INC R16
		 CPI R16,255
		 BRNE WAIT5_3

	MOV HM_master,T6_3  //Cargar posición de Decena de Horas

	LDI R16, 0b0000_1000
	OUT PORTB, R16
	LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
	LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
	ADD ZL, HM_master
	LPM HD, Z
	OUT PORTD, HD// Mostrar en display
	CLR R16	 // Wait-Esperar que se muestre valor mini-loop
	
	WAIT6_3:
		 INC R16
		 CPI R16,255
		 BRNE WAIT6_3
	 // dIAS
	MOV HM_master, T5_3	  // Verificar valores en Registros para aumentar fecha
	CPI HM_master, 9
	BRCC over_dia_u

	MOV HM_master, T6_3
	CPI HM_master, 2 
	BRCC over_dia_d

	MOV HM_master, T3_3 // MESES	 Unidades de mes
	CPI HM_master, 9
	BRCC over_mes_u

	MOV HM_master, T4_3	   // Ver si Decena de  ya esta en 1
	CPI HM_master, 1
	BRCC over_mes_d

	MOV HM_master, T4_3	  
	LDI R17, 1
	CPSE HM_master, R17
	RJMP S2

	MOV HM_master, T3_3	  // si decena y unidad mas de 2 set 00
	CPI HM_master, 2
	BRCC over_mes_d

	RJMP S2

	over_dia_u:
	CLR T5_3
	INC T6_3
	RJMP S2

	over_dia_d:
	CLR T6_3
	INC T3_3
	RJMP S2

	over_mes_u:
	CLR T3_3
	INC T4_3
	RJMP S2

	over_mes_d:
	ldi R16, 1
	MOV T3_3, R16
	CLR T4_3
	CLR T5_3
	CLR T6_3
	RJMP S2

////////////////////////////////////////////////////////////////////////
// Estado de C.F.
S3:	
	//LED modo
	LDI R16, 0b0000_0000 // red
	OUT PORTC, R16
	LDI R16, 0b0000_0000  // green
	OUT PORTB, R16

	S3_1:
		SBIS PINC, PC1// SALTA SI PC1 ES 1
		RJMP RETROpc1_S3// CAMBIO DE MODO
		CPI R26, 25 // Conteo LOOP 500ms
		BRNE S3_1
	CLR R26

	LDI R16, 0b0010_0000// green
	OUT PORTB, R16

	S3_2:
		SBIS PINC, PC1// SALTA SI PC1 ES 1
		RJMP RETROpc1_S3// CAMBIO DE MODO
		CPI R26, 25 // Conteo LOOP 	500ms 
		BRNE S3_2
	CLR R26
	////////////////////////////////////
	
	// Aumentar o Disminuir T3_3_3, T4_3_3, T5_3_3, T6_3_3 e indidar V4
	CLR T1	// clr us
	CLR T2	// clr ds

	//BOTONES
	//Modo
	SBIS PINC, PC1// SALTA SI PC1 ES 1
	RJMP RETROpc1_S3// CAMBIO DE MODO
	//SET
	SBIS PINC, PC2// SALTA SI PC2 ES 1
	RJMP RETROpc2_S3// CAMBIO DE MODO
	//RIGHT
	SBIS PINC, PC3// SALTA SI PC3 ES 1
	RJMP SEMU_3
		
	RJMP S3

	CLEAR_S3:  //over fechas
		RJMP S3
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	SEMU_3:
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEMU_3
		RJMP EMU_3

	EMU_3:  //   INC|DEC T3_3
		//SET
		SBIS PINC, PC2// SALTA SI PC2 ES 1
		RJMP RETROpc2_S3// CAMBIO DE MODO
		//RIGHT
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEMD_3
	
		//DEC
		SBIS PINC, PC4// SALTA SI PC4 ES 1
		RJMP DECEMU_3
	
		//INC
		SBIS PINC, PC5// SALTA SI PC5 ES 1
		RJMP INCEMU_3
	

		LDI R16, 0b0000_0001 // transistor 1
		OUT PORTB, R16

		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, T3_3
		LPM MU, Z
		OUT PORTD, MU// Mostrar en display

		RJMP EMU_3


	DECEMU_3:	
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,0 // Cargar valor de comparacion
		CPSE R16, T3_3  // Comparar si es 0
		RJMP DECEMU_2_3// Si si ir a decrementar

		LDI R16, 9	 // Si no cargar 9
		MOV T3_3, R16	 // cargar T6_3 con 9
	
		WAIT_DECEMU_3:  // Esperar de dejar de presionar
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEMU_3
			RJMP EMU_3
		

	DECEMU_2_3:
		CLR R16	// Limpiar registro	 arbitrario
		MOV R16, T3_3	// Cargar T6_3 en registro
		DEC R16	   // Decrementar registro
		MOV T3_3, R16	 //Cargar resultado
		WAIT_DECEMU_1_3:	// cambio de boton
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEMU_1_3
			RJMP EMU_3

	INCEMU_3:
		CLR R16	 // Limprar registro  arbitrario
		LDI R16, 9 // cargar 9  
		CPSE R16, T3_3	// verificar que no sea 9
		RJMP INCEMU_2_3// si si ir a incrementar

		LDI R16, 0	 // si no cargar 0
		MOV T3_3, R16	// cargar 0
	
		WAIT_INCEMU_3:// esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEMU_3
			RJMP EMU_3
	
	INCEMU_2_3:
		CLR R16	// limpiar registro arbitrario
		MOV R16, T3_3	// cargar T2_3
		INC R16	   // incrementar
		MOV T3_3, R16 // cargar valor a T2_3

		WAIT_INCEMU_1_3: // esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEMU_1_3
			RJMP EMU_3	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	SEMD_3:
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEMD_3
		RJMP EMD_3

	EMD_3:  //   INC|DEC T4_3
	//SET
		SBIS PINC, PC2// SALTA SI PC2 ES 1
		RJMP RETROpc2_S3// CAMBIO DE MODO
		//RIGHT
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEHU_3
	
		//DEC
		SBIS PINC, PC4// SALTA SI PC4 ES 1
		RJMP DECEMD_3
		
		//INC
		SBIS PINC, PC5// SALTA SI PC5 ES 1
		RJMP INCEMD_3
	

		LDI R16, 0b0000_0010   // transistor 2
		OUT PORTB, R16

		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, T4_3
		LPM MD, Z
		OUT PORTD, MD// Mostrar en display

		RJMP EMD_3

	DECEMD_3:	
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,0 // Cargar valor de comparacion
		CPSE R16, T4_3  // Comparar si es 0
		RJMP DECEMD_2_3 // Si si ir a decrementar

		LDI R16, 1	 // Si no cargar 1
		MOV T4_3, R16	 // cargar T3_3 con 1
	
		WAIT_DECEMD_3:  // Esperar de dejar de presionar
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEMD_3
			RJMP EMD_3
		

	DECEMD_2_3:
		CLR R16	// Limpiar registro	 arbitrario
		MOV R16, T4_3	// Cargar T3_3 en registro
		DEC R16	   // Decrementar registro
		MOV T4_3, R16	 //Cargar resultado
		WAIT_DECEMD_1_3:	// cambio de boton
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEMD_1_3
			RJMP EMD_3

	INCEMD_3:
		CLR R16	 // Limprar registro  arbitrario
		LDI R16, 1 // cargar 1
		CPSE R16, T4_3	// verificar que no sea 1
		RJMP INCEMD_2_3 // si si ir a incrementar

		LDI R16, 0	 // si no cargar 0
		MOV T4_3, R16	// cargar 0
	
		WAIT_INCEMD_3:// esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEMD_3
			RJMP EMD_3
	
	INCEMD_2_3:
		CLR R16	// limpiar registro arbitrario
		MOV R16, T4_3	// cargar T3_3
		INC R16	   // incrementar
		MOV T4_3, R16 // cargar valor a T3_3

		WAIT_INCEMD_1_3: // esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEMD_1_3
			RJMP EMD_3

	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	SEHU_3:
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEHU_3
		RJMP EHU_3

	EHU_3:   //   INC|DEC T5_3	- V4
	   //SET
		SBIS PINC, PC2// SALTA SI PC2 ES 1
		RJMP RETROpc2_S3// CAMBIO DE MODO
		//RIGHT
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEHD_3
		//RJMP RETROpc3_S3// CAMBIO DE MODO
		//DEC
		SBIS PINC, PC4// SALTA SI PC4 ES 1
		RJMP DECEHU_3
		//INC
		SBIS PINC, PC5// SALTA SI PC5 ES 1
		RJMP INCEHU_3
	

		LDI R16, 0b0000_0100   // transistor 23
		OUT PORTB, R16

		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, T5_3
		LPM HU, Z
		OUT PORTD, HU// Mostrar en display

		RJMP EHU_3

	DECEHU_3:	
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,0 // Cargar valor de comparacion
		CPSE R16, T5_3  // Comparar si es 0
		RJMP DECEHU_2_3// Si si ir a decrementar

		LDI R16, 9	 // Si no cargar 9
		MOV T5_3, R16	 // cargar T5_3 con 9
	
		WAIT_DECEHU_3:  // Esperar de dejar de presionar
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEHU_3
			RJMP EHU_3
		

	DECEHU_2_3:
		CLR R16	// Limpiar registro	 arbitrario
		MOV R16, T5_3	// Cargar T5_3 en registro
		DEC R16	   // Decrementar registro
		MOV T5_3, R16	 //Cargar resultado
		WAIT_DECEHU_1_3:	// cambio de boton
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEHU_1_3
			RJMP EHU_3

	INCEHU_3:
		CLR R16	 // Limprar registro  arbitrario
		LDI R16, 9 // cargar 9  
		CPSE R16, T5_3	// verificar que no sea 9
		RJMP INCEHU_2_3 // si si ir a incrementar

		LDI R16, 0	 // si no cargar 0
		MOV T5_3, R16	// cargar 0
	
		WAIT_INCEHU_3:// esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEHU_3
			RJMP EHU_3
	
	INCEHU_2_3:
		CLR R16	// limpiar registro arbitrario
		MOV R16, T5_3	// cargar T5_3
		INC R16	   // incrementar
		MOV T5_3, R16 // cargar valor a T5_3

		WAIT_INCEHU_1_3: // esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEHU_1_3
			RJMP EHU_3

	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	SEHD_3:
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEHD_3
		RJMP EHD_3
	EHD_3:	 //   INC|DEC T6_3 - V4
		//SET
		SBIS PINC, PC2// SALTA SI PC2 ES 1
		RJMP RETROpc2_S3// CAMBIO DE MODO
		//RIGHT
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEMU_3
		
		//DEC
		SBIS PINC, PC4// SALTA SI PC4 ES 1
		RJMP DECEHD_3
		//INC
		SBIS PINC, PC5// SALTA SI PC5 ES 1
		RJMP INCEHD_3
		

		LDI R16, 0b0000_1000 // Activar transistor de U o D 4
		OUT PORTB, R16

		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, T6_3
		LPM HD, Z
		OUT PORTD, HD// Mostrar en display

		RJMP EHD_3

	DECEHD_3:	
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,0 // Cargar valor de comparacion
		CPSE R16, T6_3  // Comparar si es 0
		RJMP DECEHD_2_3 // Si si ir a decrementar

		LDI R16, 2	 // Si no cargar 2
		MOV T6_3, R16	 // cargar T6_3 con 2
	
		WAIT_DECEHD_3:  // Esperar de dejar de presionar
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEHD_3
			RJMP EHD_3
		

	DECEHD_2_3:
		CLR R16	// Limpiar registro	 arbitrario
		MOV R16, T6_3	// Cargar T6_3 en registro
		DEC R16	   // Decrementar registro
		MOV T6_3, R16	 //Cargar resultado
		WAIT_DECEHD_1_3:	// cambio de boton
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEHD_1_3
			RJMP EHD_3

	INCEHD_3:
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,2 // cargar 2  
		CPSE R16, T6_3	// verificar que no sea 2
		RJMP INCEHD_2_3 // si si ir a incrementar

		LDI R16, 0	 // si no cargar 0
		MOV T6_3, R16	// cargar 0
	
		WAIT_INCEHD_3:// esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEHD_3
			RJMP EHD_3
	
	INCEHD_2_3:
		CLR R16	// limpiar registro arbitrario
		MOV R16, T6_3	// cargar T6_3
		INC R16	   // incrementar
		MOV T6_3, R16 // cargar valor a T6_3

		WAIT_INCEHD_1_3: // esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEHD_1_3
			RJMP EHD_3
		

	////////////////////////////////////

	RJMP S3

////////////////////////////////////////////////////////////////////////
// Alarma
S4:

	// Aumentar o Disminuir T3_4_4, T4_4_4, T5_4_4, T6_4_4 e indidar V4
	CLR T1//CLR UnidadSegundo
	CLR T2 // CLR DecenaSegundo

	//LED modo
	LDI R16, 0b0000_0001   	// LED 1 GREEN
	OUT PORTC, R16
	LDI R16, 0b0000_0000	// LED 0 RED
	OUT PORTB, R16

	S4_1:
		SBIS PINC, PC1// SALTA SI PC1 ES 1
		RJMP RETROpc1_S4// CAMBIO DE MODO
		CPI R26, 25 // Conteo LOOP DE 1s 
		BRNE S4_1
	CLR R26

	LDI R16, 0b0000_0000   // lEDS 0  GREEN
	OUT PORTC, R16
	LDI R16, 0b0010_0000   // LEDS 1 RED
	OUT PORTB, R16

	S4_2:
		SBIS PINC, PC1// SALTA SI PC1 ES 1
		RJMP RETROpc1_S4// CAMBIO DE MODO
		CPI R26, 25 // Conteo LOOP DE 1s 
		BRNE S4_2
	CLR R26

	//BOTONES
	//Modo
	SBIS PINC, PC1// SALTA SI PC1 ES 1
	RJMP RETROpc1_S4// CAMBIO DE MODO
	//SET
	SBIS PINC, PC2// SALTA SI PC2 ES 1
	RJMP RETROpc2_S4// CAMBIO DE MODO
	//RIGHT
	SBIS PINC, PC3// SALTA SI PC3 ES 1
	RJMP SEMU_4
		
	RJMP S4

	CLEAR_S4:
		RJMP S4
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	SEMU_4:
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEMU_4
		RJMP EMU_4

	EMU_4:  //   INC|DEC T3_4
		//SET
		SBIS PINC, PC2// SALTA SI PC2 ES 1
		RJMP RETROpc2_S4// CAMBIO DE MODO
		//RIGHT
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEMD_4
	
		//DEC
		SBIS PINC, PC4// SALTA SI PC4 ES 1
		RJMP DECEMU_4
	
		//INC
		SBIS PINC, PC5// SALTA SI PC5 ES 1
		RJMP INCEMU_4
	

		LDI R16, 0b0000_0001   // transistor 1
		OUT PORTB, R16

		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, T3_4
		LPM MU, Z
		OUT PORTD, MU// Mostrar en display

		RJMP EMU_4


	DECEMU_4:	
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,0 // Cargar valor de comparacion
		CPSE R16, T3_4  // Comparar si es 0
		RJMP DECEMU_2_4// Si si ir a decrementar

		LDI R16, 9	 // Si no cargar 9
		MOV T3_4, R16	 // cargar T6_4 con 9
	
		WAIT_DECEMU_4:  // Esperar de dejar de presionar
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEMU_4
			RJMP EMU_4
		

	DECEMU_2_4:
		CLR R16	// Limpiar registro	 arbitrario
		MOV R16, T3_4	// Cargar T6_4 en registro
		DEC R16	   // Decrementar registro
		MOV T3_4, R16	 //Cargar resultado
		WAIT_DECEMU_1_4:	// cambio de boton
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEMU_1_4
			RJMP EMU_4

	INCEMU_4:
		CLR R16	 // Limprar registro  arbitrario
		LDI R16, 9 // cargar 9  
		CPSE R16, T3_4	// verificar que no sea 9
		RJMP INCEMU_2_4// si si ir a incrementar

		LDI R16, 0	 // si no cargar 0
		MOV T3_4, R16	// cargar 0
	
		WAIT_INCEMU_4:// esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEMU_4
			RJMP EMU_4
	
	INCEMU_2_4:
		CLR R16	// limpiar registro arbitrario
		MOV R16, T3_4	// cargar T2_4
		INC R16	   // incrementar
		MOV T3_4, R16 // cargar valor a T2_4

		WAIT_INCEMU_1_4: // esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEMU_1_4
			RJMP EMU_4	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	SEMD_4:
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEMD_4
		RJMP EMD_4

	EMD_4:  //   INC|DEC T4_4
	//SET
		SBIS PINC, PC2// SALTA SI PC2 ES 1
		RJMP RETROpc2_S4// CAMBIO DE MODO
		//RIGHT
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEHU_4
	
		//DEC
		SBIS PINC, PC4// SALTA SI PC4 ES 1
		RJMP DECEMD_4
		
		//INC
		SBIS PINC, PC5// SALTA SI PC5 ES 1
		RJMP INCEMD_4
	

		LDI R16, 0b0000_0010  //transistor 2
		OUT PORTB, R16

		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, T4_4
		LPM MD, Z
		OUT PORTD, MD// Mostrar en display

		RJMP EMD_4

	DECEMD_4:	
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,0 // Cargar valor de comparacion
		CPSE R16, T4_4  // Comparar si es 0
		RJMP DECEMD_2_4 // Si si ir a decrementar

		LDI R16, 5	 // Si no cargar 5
		MOV T4_4, R16	 // cargar T3_4 con 5
	
		WAIT_DECEMD_4:  // Esperar de dejar de presionar
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEMD_4
			RJMP EMD_4
		

	DECEMD_2_4:
		CLR R16	// Limpiar registro	 arbitrario
		MOV R16, T4_4	// Cargar T3_4 en registro
		DEC R16	   // Decrementar registro
		MOV T4_4, R16	 //Cargar resultado
		WAIT_DECEMD_1_4:	// cambio de boton
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEMD_1_4
			RJMP EMD_4

	INCEMD_4:
		CLR R16	 // Limprar registro  arbitrario
		LDI R16, 5 // cargar 5
		CPSE R16, T4_4	// verificar que no sea 5
		RJMP INCEMD_2_4 // si si ir a incrementar

		LDI R16, 0	 // si no cargar 0
		MOV T4_4, R16	// cargar 0
	
		WAIT_INCEMD_4:// esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEMD_4
			RJMP EMD_4
	
	INCEMD_2_4:
		CLR R16	// limpiar registro arbitrario
		MOV R16, T4_4	// cargar T3_4
		INC R16	   // incrementar
		MOV T4_4, R16 // cargar valor a T3_4

		WAIT_INCEMD_1_4: // esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEMD_1_4
			RJMP EMD_4

	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	SEHU_4:
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEHU_4
		RJMP EHU_4

	EHU_4:   //   INC|DEC T5_4	- V4
	   //SET
		SBIS PINC, PC2// SALTA SI PC2 ES 1
		RJMP RETROpc2_S4// CAMBIO DE MODO
		//RIGHT
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEHD_4
		//RJMP RETROpc3_S4// CAMBIO DE MODO
		//DEC
		SBIS PINC, PC4// SALTA SI PC4 ES 1
		RJMP DECEHU_4
		//INC
		SBIS PINC, PC5// SALTA SI PC5 ES 1
		RJMP INCEHU_4
	

		LDI R16, 0b0000_0100 //transistor 3
		OUT PORTB, R16

		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, T5_4
		LPM HU, Z
		OUT PORTD, HU// Mostrar en display

		RJMP EHU_4

	DECEHU_4:	
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,0 // Cargar valor de comparacion
		CPSE R16, T5_4  // Comparar si es 0
		RJMP DECEHU_2_4// Si si ir a decrementar

		LDI R16, 9	 // Si no cargar 9
		MOV T5_4, R16	 // cargar T5_4 con 9
	
		WAIT_DECEHU_4:  // Esperar de dejar de presionar
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEHU_4
			RJMP EHU_4
		

	DECEHU_2_4:
		CLR R16	// Limpiar registro	 arbitrario
		MOV R16, T5_4	// Cargar T5_4 en registro
		DEC R16	   // Decrementar registro
		MOV T5_4, R16	 //Cargar resultado
		WAIT_DECEHU_1_4:	// cambio de boton
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEHU_1_4
			RJMP EHU_4

	INCEHU_4:
		CLR R16	 // Limprar registro  arbitrario
		LDI R16, 9 // cargar 9  
		CPSE R16, T5_4	// verificar que no sea 9
		RJMP INCEHU_2_4 // si si ir a incrementar

		LDI R16, 0	 // si no cargar 0
		MOV T5_4, R16	// cargar 0
	
		WAIT_INCEHU_4:// esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEHU_4
			RJMP EHU_4
	
	INCEHU_2_4:
		CLR R16	// limpiar registro arbitrario
		MOV R16, T5_4	// cargar T5_4
		INC R16	   // incrementar
		MOV T5_4, R16 // cargar valor a T5_4

		WAIT_INCEHU_1_4: // esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEHU_1_4
			RJMP EHU_4

	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	SEHD_4:
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEHD_4
		RJMP EHD_4
	EHD_4:	 //   INC|DEC T6_4 - V4
		//SET
		SBIS PINC, PC2// SALTA SI PC2 ES 1
		RJMP RETROpc2_S4// CAMBIO DE MODO
		//RIGHT
		SBIS PINC, PC3// SALTA SI PC3 ES 1
		RJMP SEMU_4
		
		//DEC
		SBIS PINC, PC4// SALTA SI PC4 ES 1
		RJMP DECEHD_4
		//INC
		SBIS PINC, PC5// SALTA SI PC5 ES 1
		RJMP INCEHD_4
		

		LDI R16, 0b0000_1000 // Activar transistor de U o D
		OUT PORTB, R16

		LDI ZH, HIGH(TABLA7U <<1); BIT MAS SIGNIFICATIVO
		LDI ZL, LOW(TABLA7U<<1); BIT MENOS SIGNIFICATIVO
		ADD ZL, T6_4
		LPM HD, Z
		OUT PORTD, HD// Mostrar en display

		RJMP EHD_4

	DECEHD_4:	
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,0 // Cargar valor de comparacion
		CPSE R16, T6_4  // Comparar si es 0
		RJMP DECEHD_2_4 // Si si ir a decrementar

		LDI R16, 2	 // Si no cargar 2
		MOV T6_4, R16	 // cargar T6_4 con 2
	
		WAIT_DECEHD_4:  // Esperar de dejar de presionar
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEHD_4
			RJMP EHD_4
		

	DECEHD_2_4:
		CLR R16	// Limpiar registro	 arbitrario
		MOV R16, T6_4	// Cargar T6_4 en registro
		DEC R16	   // Decrementar registro
		MOV T6_4, R16	 //Cargar resultado
		WAIT_DECEHD_1_4:	// cambio de boton
			SBIS PINC, PC4// SALTA SI PC4 ES 1
			RJMP WAIT_DECEHD_1_4
			RJMP EHD_4

	INCEHD_4:
		CLR R16	 // Limprar registro  arbitrario
		LDI R16,2 // cargar 2  
		CPSE R16, T6_4	// verificar que no sea 2
		RJMP INCEHD_2_4 // si si ir a incrementar

		LDI R16, 0	 // si no cargar 0
		MOV T6_4, R16	// cargar 0
	
		WAIT_INCEHD_4:// esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEHD_4
			RJMP EHD_4
	
	INCEHD_2_4:
		CLR R16	// limpiar registro arbitrario
		MOV R16, T6_4	// cargar T6_4
		INC R16	   // incrementar
		MOV T6_4, R16 // cargar valor a T6_4

		WAIT_INCEHD_1_4: // esperar cambio de boton
			SBIS PINC, PC5// SALTA SI PC5 ES 1
			RJMP WAIT_INCEHD_1_4
			RJMP EHD_4
		

	////////////////////////////////////

	RJMP S4
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
// Botones|Manejo de Estados
////////////////////////////////////////////////////////////////////
//******************************************************
RETROpc1_S0:
	SBIC PINC, PC1 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S1
	RJMP RETROpc1_S0
//******************************************************
RETROpc5_S1:
	SBIC PINC, PC5 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S1
	RJMP RETROpc5_S1
									
RETROpc4_S1:
	SBIC PINC, PC4 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S1
	RJMP RETROpc4_S1

RETROpc3_S1:
	SBIC PINC, PC3 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S1
	RJMP RETROpc3_S1

RETROpc2_S1:
	SBIC PINC, PC2 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S0
	RJMP RETROpc2_S1

//******************************************************
//******************************************************
RETROpc1_S1:
	SBIC PINC, PC1 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S2
	RJMP RETROpc1_S1
//******************************************************
RETROpc1_S2:
	SBIC PINC, PC1 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S3
	RJMP RETROpc1_S2
//******************************************************
//******************************************************
RETROpc5_S3:
	SBIC PINC, PC5 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S3
	RJMP RETROpc5_S3

RETROpc4_S3:
	SBIC PINC, PC4 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S3
	RJMP RETROpc4_S3

RETROpc3_S3:
	SBIC PINC, PC3 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S3
	RJMP RETROpc3_S3

RETROpc2_S3:
	SBIC PINC, PC2 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S2
	RJMP RETROpc2_S3
//******************************************************
//******************************************************
RETROpc1_S3:
	SBIC PINC, PC1 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S4
	RJMP RETROpc1_S3
//******************************************************
//******************************************************
RETROpc5_S4:
	SBIC PINC, PC5 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S4
	RJMP RETROpc5_S4
									
RETROpc4_S4:
	SBIC PINC, PC4 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S4
	RJMP RETROpc4_S4

RETROpc3_S4:
	SBIC PINC, PC3 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S4
	RJMP RETROpc3_S4

RETROpc2_S4:
	SBIC PINC, PC2 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S0
	RJMP RETROpc2_S4

//******************************************************
//******************************************************
RETROpc1_S4:
	SBIC PINC, PC1 // SALTA SI ESTA EN 0  = PRESIONADO
	RJMP S0
	RJMP RETROpc1_S4
//******************************************************
//******************************************************

////////////////////////////////////////////////////////////////////
// Apartado de TIEMR0
////////////////////////////////////////////////////////////////////
Init_T0:
	LDI R16, (1<< CS02)|(1<<CS00)  ; Configurar el prescaler a 1024 
	;para un reloj de 16MHz
	OUT TCCR0B, R16

	LDI R16, 100			;Cargar el valor de desbordamiento
	OUT TCNT0, R16		;Cargar el valor inicial del contador

	LDI R16, (1<<TOIE0); Habilitar interrupcion por overflow
	STS TIMSK0, R16
	RET

ISR_TIMER0_OVF:
	PUSH R16	  //Intput STACK
	IN R16, SREG
	PUSH R16

	LDI R16, 100	;Cargar el valor de desbordamiento
	OUT TCNT0, R16	;Cargar el valor inicial del Contador
	SBI TIFR0,TOV0	;Borramos la bandera de TOV0
	INC R26			;Incrementamos contador de 10ms


	POP R16		   // Output STACK
	OUT SREG, R16
	POP R16
	RETI	