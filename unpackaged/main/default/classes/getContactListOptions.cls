global with sharing class getContactListOptions implements  Callable {
    /*public Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
        return invokeMethod(action, input, output, options);
     }*/
 
     /*public Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
     {
         try {
             if (methodName.equals('SelectOptions'))
             {
                 SelectOptions(inputMap, outMap, options);
             }
         }
         catch(Exception e) {
             System.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
         }
         return true;
     }*/

     global Object call(String action, Map<String, Object> args)
    {
        System.debug(String.valueOf(args));
        switch on action {
            when 'SelectOptions' {
                return SelectOptions((Map<String, Object>)args.get('input'), 
                    (Map<String, Object>)args.get('output'));
            }
        }
        return null;
    }
    
     private List<Map<String, Object>> SelectOptions(Map<String, Object> inputMap, Map<String, Object> outMap)
     {
         List<Map<String, Object>> optionList = new List<Map<String, Object>>();
         System.debug('inputMap'+inputMap);
         String accountId = String.valueOf(inputMap.get('AccountId'));
         for (Contact cnt : [ Select Id, Name, Email from Contact WHERE AccountId = :AccountId])
         {
              Map<String, Object> option = new Map<String, Object>();
              option.put('name', cnt.Email);
              option.put('value', cnt.Name);
              optionList.add(option);
         }
         
         outMap.put('options', optionList);
                 
         return optionList;
     }
}