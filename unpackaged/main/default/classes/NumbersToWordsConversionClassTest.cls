@isTest
public with sharing class NumbersToWordsConversionClassTest {
    @isTest
    public static void simpleConversionTest(){
        NumbersToWordsConversionClass num2text = new NumbersToWordsConversionClass('EURO', 'EUROS', 'CÉNTIMO', 'CÉNTIMOS', true);
        
        System.assertEquals('MIL NOVECIENTOS OCHENTA Y UN EUROS', num2text.convert((Double) 1981));
        System.assertEquals('DOS MILLONES QUINIENTOS VEINTIOCHO MIL TRESCIENTOS CUARENTA Y SIETE EUROS CON VEINTICUATRO CÉNTIMOS', num2text.convert((Double) 2528347.24));
        System.assertEquals('CIENTO DIECISÉIS MILLONES NOVECIENTOS SETENTA Y DOS MIL QUINIENTOS NOVENTA Y NUEVE EUROS CON CINCUENTA Y UN CÉNTIMOS', num2text.convert((Double) 116972599.51));
        
        num2text = new NumbersToWordsConversionClass('PESETA', 'PESETAS', 'CÉNTIMO', 'CÉNTIMOS', false);
        System.assertEquals('NOVENTA Y UNA PESETAS', num2text.convert((Double) 91));
        System.assertEquals('UNA PESETA CON CINCO CÉNTIMOS', num2text.convert((Double) 1.05));
        System.assertEquals('MIL UNA PESETAS CON CINCUENTA CÉNTIMOS', num2text.convert((Double) 1001.50));

    }
    
    public static void edgesConversionTest(){
        NumbersToWordsConversionClass num2text = new NumbersToWordsConversionClass('EURO', 'EUROS', 'CÉNTIMO', 'CÉNTIMOS', true);
        // Millones
        System.assertEquals('UN MILLÓN DE EUROS', num2text.convert((Double) 1000000));
        System.assertEquals('CINCO MILLONES DE EUROS', num2text.convert((Double) 5000000));
        // Cero
        System.assertEquals('CERO EUROS', num2text.convert((Double) 0));
        // Sólo decimales
        System.assertEquals('VEINTIDÓS CÉNTIMOS', num2text.convert((Double) 0.22));
        // Un céntimo
        System.assertEquals('UN CÉNTIMO', num2text.convert((Double) 0.01));
        // Cien
        System.assertEquals('CIEN EUROS', num2text.convert((Double) 100));
    }
    
    /**
     * Prueba específicamente la función de unidades
     */
    @isTest
    public static void unitsTest(){
        NumbersToWordsConversionClass num2text = new NumbersToWordsConversionClass('EURO', 'EUROS', 'CÉNTIMO', 'CÉNTIMOS',true);
        System.assertEquals('',num2text.units(0));
        System.assertEquals('UN',num2text.units(1));
        System.assertEquals('DOS',num2text.units(2));
        System.assertEquals('TRES',num2text.units(3));
        System.assertEquals('CUATRO',num2text.units(4));
        System.assertEquals('CINCO',num2text.units(5));
        System.assertEquals('SEIS',num2text.units(6));
        System.assertEquals('SIETE',num2text.units(7));
        System.assertEquals('OCHO',num2text.units(8));
        System.assertEquals('NUEVE',num2text.units(9));
        
        num2text = new NumbersToWordsConversionClass('EURO', 'EUROS', 'CÉNTIMO', 'CÉNTIMOS',false);
        System.assertEquals('UNA',num2text.units(1));
    }
    
    /**
     * Prueba específicamente los casos principales de la función de decenas
     */
    @isTest
    public static void tentsTest(){
        NumbersToWordsConversionClass num2text = new NumbersToWordsConversionClass('EURO', 'EUROS', 'CÉNTIMO', 'CÉNTIMOS',true);
        System.assertEquals('DIEZ',num2text.tents(10));
        System.assertEquals('ONCE',num2text.tents(11));
        System.assertEquals('DOCE',num2text.tents(12));
        System.assertEquals('TRECE',num2text.tents(13));
        System.assertEquals('CATORCE',num2text.tents(14));
        System.assertEquals('QUINCE',num2text.tents(15));
        System.assertEquals('DIECISÉIS',num2text.tents(16));
        System.assertEquals('DIECISIETE',num2text.tents(17));
        System.assertEquals('DIECIOCHO',num2text.tents(18));
        System.assertEquals('DIECINUEVE',num2text.tents(19));

        System.assertEquals('VEINTE',num2text.tents(20));
        System.assertEquals('VEINTIÚN',num2text.tents(21));
        System.assertEquals('VEINTIDÓS',num2text.tents(22));
        System.assertEquals('VEINTITRÉS',num2text.tents(23));
        System.assertEquals('VEINTICUATRO',num2text.tents(24));
        System.assertEquals('VEINTICINCO',num2text.tents(25));
        System.assertEquals('VEINTISÉIS',num2text.tents(26));
        System.assertEquals('VEINTISIETE',num2text.tents(27));
        System.assertEquals('VEINTIOCHO',num2text.tents(28));
        System.assertEquals('VEINTINUEVE',num2text.tents(29));

        System.assertEquals('TREINTA Y UN',num2text.tents(31));
        System.assertEquals('CUARENTA Y DOS',num2text.tents(42));
        System.assertEquals('CINCUENTA Y TRES',num2text.tents(53));
        System.assertEquals('SESENTA Y CUATRO',num2text.tents(64));
        System.assertEquals('SETENTA Y CINCO',num2text.tents(75));
        System.assertEquals('OCHENTA Y SEIS',num2text.tents(86));
        System.assertEquals('NOVENTA Y SIETE',num2text.tents(97));
    }
    
    /**
     * Prueba específicamente los casos principales de la función de centenas
     */
    @isTest
    public static void hundredsTest(){
		NumbersToWordsConversionClass num2text = new NumbersToWordsConversionClass('EURO', 'EUROS', 'CÉNTIMO', 'CÉNTIMOS',true);
        System.assertEquals('CIEN',num2text.hundreds(100));
        System.assertEquals('CIENTO UN',num2text.hundreds(101));
        
        System.assertEquals('DOSCIENTOS',num2text.hundreds(200).trim());
    }
}