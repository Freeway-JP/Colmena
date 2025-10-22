public with sharing class WsHabeasDataMassiveBach implements Database.Batchable<WSHabeasDataAPIDto.HabeasDataDTO>, Database.Stateful {
    //WSHabeasDataAPIDto.HabeasDataDTO
    //WSHabeasDataExtendWrapper.HabeasDataDTO
    private final List<WSHabeasDataAPIDto.HabeasDataDTO> inbound;
    private final String massiveType;

    public Integer successCount = 0, errorCount = 0;

    public WsHabeasDataMassiveBach(List<WSHabeasDataAPIDto.HabeasDataDTO> inbound, String massiveType) {
        this.inbound = inbound == null ? new List<WSHabeasDataAPIDto.HabeasDataDTO>() : inbound;
        this.massiveType = massiveType;
    }

    public Iterable<WSHabeasDataAPIDto.HabeasDataDTO> start(Database.BatchableContext bc) {
        return new IterableList(inbound);
    }

    public void execute(Database.BatchableContext bc, List<WSHabeasDataAPIDto.HabeasDataDTO> scope) {
        WSHabeasDataService svc = new WSHabeasDataService();
        for (WSHabeasDataAPIDto.HabeasDataDTO dto : scope) {
            System.debug('To be proccesed => ' + dto);
            WSHabeasDataAPIDto.ResponseDto r = svc.processAuth(dto);
            System.debug('Proceced => ' + r);
            if (!r.error)
                successCount++;
            else
                errorCount++;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('AuthorizationBatch finished. OK=' + successCount + ' ERR=' + errorCount + ' TYPE=' + massiveType);
        // TODO: publicar Platform Event / Email resumen
    }

    public class IterableList implements Iterable<WSHabeasDataAPIDto.HabeasDataDTO> {
        List<WSHabeasDataAPIDto.HabeasDataDTO> data;
        public IterableList(List<WSHabeasDataAPIDto.HabeasDataDTO> d) {
            data = d;
        }
        public Iterator<WSHabeasDataAPIDto.HabeasDataDTO> iterator() {
            return new Iter(data);
        }
    }

    public class Iter implements Iterator<WSHabeasDataAPIDto.HabeasDataDTO> {
        List<WSHabeasDataAPIDto.HabeasDataDTO> data;
        Integer i = 0;
        public Iter(List<WSHabeasDataAPIDto.HabeasDataDTO> d) {
            data = d;
        }
        public Boolean hasNext() {
            return i < data.size();
        }
        public WSHabeasDataAPIDto.HabeasDataDTO next() {
            return data[i++];
        }
    }
}