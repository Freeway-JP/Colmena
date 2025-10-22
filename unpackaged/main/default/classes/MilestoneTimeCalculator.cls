global class MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId WITH SECURITY_ENFORCED];
        
		DateTime today = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Integer targetMonth = today.month() + 1;// Calcular el mes siguiente
        Integer targetYear = today.year();
        
        if (targetMonth > 12) {            targetMonth -= 12;            targetYear += 1;
        }
        
        Integer lastDay = Date.daysInMonth(targetYear, targetMonth);// Obtener el último día del mes siguiente
        Date finalDate = Date.newInstance(targetYear, targetMonth, lastDay);
        System.debug('Fecha objetivo: ' + finalDate);
        
		DateTime targetDateTime = DateTime.newInstance(finalDate, Time.newInstance(0, 0, 0, 0));

        Long diffMillis = BusinessHours.diff(System.Label.PQRSOfficeScheduleId, today, targetDateTime);
        
        Long milisegundos = diffMillis; // ejemplo: 1 hora
        Long minutos = milisegundos / (60 * 1000);
        System.debug('Minutos: ' + minutos);

        Integer intTimeANS = Integer.valueOf(minutos);
               
        return intTimeANS;
    }
}