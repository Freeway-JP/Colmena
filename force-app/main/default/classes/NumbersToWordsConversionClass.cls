public with sharing class NumbersToWordsConversionClass {
    // Texto de moneda en plural
    String currencyPluralForm = 'PESOS';
    // Texto de moneda en singular
    String currencySingularForm = 'PESO';
    // Indica si la moneda es masculina o femenina
    boolean isMasculine = true;
    // Texto de centavos en plural
    String centsPluralForm = 'CÉNTIMOS';
    // Texto de centavos en singular
	String centsSingularForm = 'CÉNTIMO';
    
    /**
     * @description	Constructor
     * @param	currencySingular	Texto de la moneda en singular, p.e. PESO
     * @param	currencyPlural		Texto de la moneda en plural, p.e. PESOS
     * @param	centsSingular		Texto de los centavos en singular, p.e. CENTAVO
     * @param	centsPlural			Texto de los centavos en plural, p.e. CENTAVOS
     * @param	isMasculine			Si la moneda es masculina (true, como en peso) o femenina (false, como en peseta)
     */
    public NumbersToWordsConversionClass(String currencySingular, String currencyPlural, String centsSingular, String centsPlural, Boolean isMasculine){
        this.currencySingularForm = currencySingular;
        this.currencyPluralForm = currencyPlural;
        this.centsSingularForm = centsSingular;
        this.centsPluralForm = centsPlural;
        this.isMasculine = isMasculine;
    }

    /**
     * @description	devuelve las unidades para un número de una cifra
     * @param	num	el número de la unidad
     * @return el texto de la unidad
     */
	@testVisible
    private String units(Integer num){
    
        switch on num
        {
            when 1 { if(isMasculine){ return 'UN'; } else { return 'UNA'; }}
            when 2 { return 'DOS'; }
            when 3 { return 'TRES'; }
            when 4 { return 'CUATRO'; }
            when 5 { return 'CINCO'; }
            when 6 { return 'SEIS'; }
            when 7 { return 'SIETE'; }
            when 8 { return 'OCHO'; }
            when 9 { return 'NUEVE'; }
        }
    
        return '';
    }

	/**
     * @description	devuelve las decenas y unidades para un número de dos cifras
     * @param	num	el número de dos cifras
     * @return el texto correspondiente
     */
    @testVisible
	private String tents(Double num){

    	Integer decena = (Integer) Math.floor(num/10);
    	Integer unidad = (Integer) Math.floor(num - (decena * 10));

        switch on decena
        {
            when 1 {
                switch on unidad
                {
                    when 0 { return 'DIEZ'; }
                    when 1 { return 'ONCE'; }
                    when 2 { return 'DOCE'; }
                    when 3 { return 'TRECE'; }
                    when 4 { return 'CATORCE'; }
                    when 5 { return 'QUINCE'; }
                    when else { return 'DIECI' + unitsTents(unidad); }
                }
            }
            when 2 {
                switch on unidad
                {
                    when 0 { return 'VEINTE'; }
                    when else { return 'VEINTI' + unitsTents(unidad); }
                }
            }
            when 3 { return tentsAnd('TREINTA', unidad); }
            when 4 { return tentsAnd('CUARENTA', unidad); }
            when 5 { return tentsAnd('CINCUENTA', unidad); }
            when 6 { return tentsAnd('SESENTA', unidad); }
            when 7 { return tentsAnd('SETENTA', unidad); }
            when 8 { return tentsAnd('OCHENTA', unidad); }
            when 9 { return tentsAnd('NOVENTA', unidad); }
            when 0 { return units(unidad); }
        }
        return '';
    }
    
	/**
     * @description	devuelve las decenas y unidades para un número de dos cifras, unidas por "y"
     * @param	strSin	El prefijo de las decenas
     * @param	num	el número de las unidades
     * @return el texto correspondiente, por ejemplo SESENTA Y DOS
     */
    @testVisible
    private String tentsAnd(String strSin, Integer numUnidades) {
        if (numUnidades > 0){
            return strSin + ' Y ' + units(numUnidades);
        } else{
            return strSin;
        }
    }

    /**
     * @description	devuelve el texto de las unidades el caso de 1x y 2x
     * @param	num	la unidad
     * @return el texto correspondiente, por ejemplo, veintiún, dieciséis
     */
    @testVisible
    private String unitsTents(Integer num){
    
        switch on num
        {
            when 1 { if(isMasculine){ return 'ÚN'; } else { return 'UNA'; }}
            when 2 { return 'DÓS'; }
            when 3 { return 'TRÉS'; }
            when 4 { return 'CUATRO'; }
            when 5 { return 'CINCO'; }
            when 6 { return 'SÉIS'; }
            when 7 { return 'SIETE'; }
            when 8 { return 'OCHO'; }
            when 9 { return 'NUEVE'; }
        }
    
        return '';
    }//units()

	/**
     * @description	devuelve las centenas, decenas y unidades para un número de tres cifras
     * @param	num	el número de tres cifras
     * @return el texto correspondiente
     */    
    @testVisible
    private String hundreds(Double num) {
        Integer centenas = (Integer) Math.floor(num / 100);
        Integer decenas = (Integer) Math.floor(num - (centenas * 100));
    
        switch on centenas
        {
            when 1 {
                if (decenas > 0){
                    return 'CIENTO ' + tents(decenas);
                } else {
                    return 'CIEN';
                }
            }
            when 2 { return 'DOSCIENTOS ' + tents(decenas); }
            when 3 { return 'TRESCIENTOS ' + tents(decenas); }
            when 4 { return 'CUATROCIENTOS ' + tents(decenas); }
            when 5 { return 'QUINIENTOS ' + tents(decenas); }
            when 6 { return 'SEISCIENTOS ' + tents(decenas); }
            when 7 { return 'SETECIENTOS ' + tents(decenas); }
            when 8 { return 'OCHOCIENTOS ' + tents(decenas); }
            when 9 { return 'NOVECIENTOS ' + tents(decenas); }
        }
    
        return tents(decenas);
    }//hundreds()

	/**
     * @description	devuelve una sección regular
     * @param	num	el número a describir
     * @param	divisor	el divisor para la posición de unidades (p. ej. 1000 para millares)
     * @param	strSingular	el texto de la unidad de medida en caso singular (p. ej. MILLÓN)
     * @param	strPlural	el texto de la unidad de medida en caso plural (p. ej. MILLONES)
     * @return el texto correspondiente
     */    
    @testVisible
    private String section(Double num, Integer divisor, String strSingular, String strPlural) {
        Integer cientos = (Integer) Math.floor(num / divisor);
        Double resto = (Double) (num - (cientos * divisor));
    
        String letras = '';
    
        if (cientos > 0){
            if (cientos > 1){
                letras = hundreds(cientos) + ' ' + strPlural;
            }else{
                letras = strSingular;
            }
        }
    
        if (resto > 0){
            letras += '';
        }
    
        return letras;
    }//section()

	/**
     * @description	devuelve los miles, las centenas, decenas y unidades para un número de cuatro o mas cifras
     * @param	num	el número de cuatro o más cifras
     * @return el texto correspondiente
     */        
    @testVisible
    private String thousands(Double num) {
        Integer divisor = 1000;
        Integer cientos = (Integer) Math.floor(num / divisor);
        Double resto = num - (cientos * divisor);
    
        String strMiles = section(num, divisor, 'MIL', 'MIL');
        String strCentenas = hundreds(resto);
    
        if(strMiles == ''){
            return strCentenas;
        }
    
        return strMiles + ' ' + strCentenas;
    }//thousands()

	/**
     * @description	devuelve los millones, los miles, las centenas, decenas y unidades para un número de seis o mas cigras
     * @param	num	el número de seis o más cifras
     * @return el texto correspondiente
     */           
    @testVisible
    private String millions(Double num) {
        Integer divisor = 1000000;
        Integer cientos = (Integer) Math.floor(num / divisor);
        Double resto = num - (cientos * divisor);
    
        String strMiles = thousands(resto);
        String strMillones = '';
        if(strMiles.trim().equals('')){
        	strMillones = section(num, divisor, 'MILLÓN DE', 'MILLONES DE');
        }else{
            strMillones = section(num, divisor, 'MILLÓN', 'MILLONES');
        }
            
        if(strMillones == ''){
            return strMiles;
        }
    
        return strMillones + ' ' + strMiles;
    }
    

    /**
     * @description Convierte un número en la representación en texto de sus cifras, con dos decimales, utilizando el formato configurado
     * @param	num	El número a convertir, p. ej 118.08
     * @return	El número en forma escrita en mayúsculas, p.ej. CIENTO DIECIOCHO EUROS CON OCHO CÉNTIMOS
     */
    public String convert(Double num){
        NumberData data = new NumberData(num);
        String res = '';
        String resCentavos = '';
        
        String strCentavos = '';
        if(data.centavos > 0){    
            if (data.centavos == 1){
                strCentavos = millions(data.centavos) + ' ' + this.centsSingularForm;
            }else {
                strCentavos = millions(data.centavos) + ' ' + this.centsPluralForm;
            }
            resCentavos = 'CON '+strCentavos;            
        }
        
        if(data.enteros == 0){
            res = 'CERO '+this.currencyPluralForm + ' ' + strCentavos;
        }else if (data.enteros == 1){
            res = millions(data.enteros) + ' ' + this.currencySingularForm + ' ' + resCentavos;
        }else{
            res = millions(data.enteros) + ' ' + this.currencyPluralForm + ' ' + resCentavos;
        }
        
        return res.trim();
    }
    
    /**
     * Representa los datos de trabajo del número
     */
    private class NumberData {
        // El número completo
        Double numero;
        // La parte entera del número
        Long enteros;
        // Los céntimos, representados con dos decimales
        Integer centavos;
        
        NumberData(Double num){
            this.numero = num;
            this.enteros = (Long) Math.floor(num);
            // Calculamos los centavos
            Double porDiez = (Double) num * 100;
            Double porDiezSinDec = (Math.floor(num) * 100);
            this.centavos = (Integer) (porDiez-porDiezSinDec);
            System.debug(System.LoggingLevel.DEBUG,'Numero '+this.numero);
            System.debug(System.LoggingLevel.DEBUG,'Enteros '+this.enteros);
            System.debug(System.LoggingLevel.DEBUG,'Centavos '+this.centavos);
        }
    }
}