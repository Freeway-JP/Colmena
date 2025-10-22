global with sharing class SlipDataHelper implements Callable {
    global Object call(String action, Map<String, Object> args) {
        System.debug('Entering SlipDataHelper call method');
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        System.debug('Entering SlipDataHelper invokeMethod: ' + methodName);
        Boolean result = true;
        try {
            if (methodName.equals('getInsuredValueLabel')) {
                List<Object> arguments = (List<Object>)inputMap.get('arguments');
                outMap.put('result', getInsuredValueLabel(arguments));
            } else if (methodName.equals('getApiValueByName')) {
                List<Object> arguments = (List<Object>)inputMap.get('arguments');
                outMap.put('result', getApiValueByName(arguments));
            } else if (methodName.equals('getExpeditionnDate')) {
                outMap.put('result', getExpeditionnDate());
            } else if (methodName.equals('deduplicateCoveragesByName')) {
                List<Object> arguments = (List<Object>)inputMap.get('arguments');
                outMap.put('result', deduplicateCoveragesByName(arguments));
            } else {
                result = false;
            }
        } catch(Exception e) {
            System.debug('Exception in SlipDataHelper invokeMethod: ' + e.getMessage());
            System.debug('LineNumber: ' + e.getLineNumber());
            System.debug('StackTrace: ' + e.getStackTraceString());
            System.debug('TypeName: ' + e.getTypeName());
            result = false;
        }
        return result;
    }
    
    public Object getInsuredValueLabel(List<Object> productCoverageList) {
        System.debug('Processing product coverages for insured value label, count: ' + (productCoverageList != null ? productCoverageList.size() : 0));
        
        if (productCoverageList == null || productCoverageList.isEmpty()) {
            return 'No aplica';
        }
        
        // Obtener planes únicos
        Set<String> uniquePlanNames = new Set<String>();
        
        for (Object coverage : productCoverageList) {
            if (coverage != null) {
                try {
                    Map<String, Object> coverageMap = (Map<String, Object>) coverage;
                    String planName = (String) coverageMap.get('Plan__r.Name');
                    
                    if (String.isNotBlank(planName)) {
                        uniquePlanNames.add(planName);
                    }
                } catch (Exception e) {
                    System.debug('Error processing coverage item: ' + e.getMessage());
                    continue;
                }
            }
        }
        
        System.debug('Unique plans found: ' + uniquePlanNames.size());
        
        // Aplicar el criterio: si hay varios planes retornar "Planes", si es uno solo retornar el nombre
        if (uniquePlanNames.size() > 1) {
            return 'Planes';
        } else if (uniquePlanNames.size() == 1) {
            return new List<String>(uniquePlanNames)[0];
        } else {
            return 'No aplica';
        }
    }

    public String getApiValueByName(Object inputArguments) {
        System.debug('API value input received: ' + inputArguments);
        
        String apiValue = null;
        
        if (inputArguments instanceof List<Object>) {
            List<Object> inputList = (List<Object>) inputArguments;
            if (!inputList.isEmpty() && inputList[0] != null) {
                apiValue = inputList[0].toString();
            }
        }
        
        if (String.isBlank(apiValue)) {
            return null;
        }
        
        System.debug('Extracted API value: ' + apiValue);
        
        // Mapa de API values (números) a nombres
        Map<String, String> apiToRoleMap = new Map<String, String>{
            '1' => 'Tomador',
            '2' => 'Asegurado',
            '3' => 'Tercero',
            '4' => 'Conductor habitual',
            '5' => 'Contacto Cartera',
            '6' => 'Contragarante',
            '7' => 'Co-Asegurado',
            '8' => 'Afianzado',
            '9' => 'Clinica',
            '10' => 'Taller',
            '11' => 'Call Center',
            '14' => 'Asegurado Afectado',
            '15' => 'Endosatorio',
            '16' => 'Beneficiario',
            '17' => 'Empleado Doméstico',
            '20' => 'Aseg. accidentes personales',
            '21' => 'Padres',
            '22' => 'Hijo(a)',
            '23' => 'Cónyuge',
            '24' => 'Hermano',
            '25' => 'Pagador',
            '26' => 'Sponsor/Grupo Empresarial',
            '27' => 'Suegros',
            '28' => 'Compañero Permanente',
            '29' => 'Hijastro (a)',
            '30' => 'Hijo Adoptivo',
            '31' => 'Denunciante',
            '32' => 'Cuñado (a)',
            '33' => 'Nuera - Yerno',
            '34' => 'Bisnieto (a)',
            '35' => 'Empleado Confianza',
            '50' => 'Liquidador',
            '51' => 'Conductor',
            '60' => 'Hijo Discapacitado',
            '65' => 'Ejecutivo comercial',
            '66' => 'Carga Medica',
            '67' => 'Nietos',
            '68' => 'Abuelos',
            '69' => 'Otros',
            '70' => 'Contratante secundario',
            '71' => 'Administrador pólizas',
            '72' => 'Administrador asegurados',
            '73' => 'Administrador recaudación',
            '74' => 'Duplo',
            '75' => 'Tutor',
            '76' => 'Tíos',
            '77' => 'Primos',
            '78' => 'Sobrinos',
            '79' => 'Chofer',
            '80' => 'Deudor',
            '81' => 'CoDeudor',
            '82' => 'Aval',
            '85' => 'Empresa Empleadora',
            '86' => 'Adicionales',
            '90' => 'Representante legal',
            '91' => 'Soporte Comercial',
            '92' => 'Consultor Comercial',
            '93' => 'Referidor',
            '10000' => 'Desconocido'
        };
        
        String roleName = apiToRoleMap.get(apiValue);
        System.debug('Mapped role name: ' + roleName);
        
        return roleName;
    }

    public String getExpeditionnDate() {
        System.debug('Generating expedition date');
        
        Date today = Date.today();
        DateTime todayDateTime = DateTime.newInstance(today, Time.newInstance(0, 0, 0, 0));
        
        // Mapas para traducir días y meses al español
        Map<String, String> dayMap = new Map<String, String>{
            'Monday' => 'Lunes',
            'Tuesday' => 'Martes', 
            'Wednesday' => 'Miércoles',
            'Thursday' => 'Jueves',
            'Friday' => 'Viernes',
            'Saturday' => 'Sábado',
            'Sunday' => 'Domingo'
        };
        
        Map<Integer, String> monthMap = new Map<Integer, String>{
            1 => 'Enero',
            2 => 'Febrero',
            3 => 'Marzo',
            4 => 'Abril',
            5 => 'Mayo',
            6 => 'Junio',
            7 => 'Julio',
            8 => 'Agosto',
            9 => 'Septiembre',
            10 => 'Octubre',
            11 => 'Noviembre',
            12 => 'Diciembre'
        };
        
        // Obtener día de la semana en inglés y traducir
        String dayOfWeekEn = todayDateTime.format('EEEE');
        String dayOfWeekEs = dayMap.get(dayOfWeekEn);
        
        // Obtener día del mes
        Integer dayOfMonth = today.day();
        
        // Obtener mes y traducir
        Integer monthNumber = today.month();
        String monthEs = monthMap.get(monthNumber);
        
        // Obtener año
        Integer year = today.year();
        
        // Formatear la fecha completa
        String expeditionDate = dayOfWeekEs + ' ' + dayOfMonth + ' de ' + monthEs + ' de ' + year;
        
        System.debug('Formatted expedition date: ' + expeditionDate);
        
        return expeditionDate;
    }

    public Map<String, Object> deduplicateCoveragesByName(List<Object> coverageList) {
        System.debug('Processing coverages for deduplication by name, count: ' + (coverageList != null ? coverageList.size() : 0));
        
        if (coverageList == null || coverageList.isEmpty()) {
            Map<String, Object> result = new Map<String, Object>();
            result.put('Coverages', new List<Object>());
            return result;
        }
        
        Map<String, Object> uniqueCoverages = new Map<String, Object>();
        
        for (Object coverage : coverageList) {
            if (coverage != null) {
                try {
                    Map<String, Object> coverageMap = (Map<String, Object>) coverage;
                    String coverageName = (String) coverageMap.get('Cobertura');
                    
                    if (String.isNotBlank(coverageName)) {
                        // Solo agregar si no existe ya en el mapa (mantiene la primera ocurrencia)
                        if (!uniqueCoverages.containsKey(coverageName)) {
                            uniqueCoverages.put(coverageName, coverage);
                        }
                    }
                } catch (Exception e) {
                    System.debug('Error processing coverage item for deduplication: ' + e.getMessage());
                    continue;
                }
            }
        }
        
        System.debug('Unique coverages found: ' + uniqueCoverages.size());
        
        // Retornar con el nodo "Coverages"
        Map<String, Object> result = new Map<String, Object>();
        result.put('Coverages', uniqueCoverages.values());
        return result;
    }
}