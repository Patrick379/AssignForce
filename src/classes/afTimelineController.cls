public class afTimelineController {
    
    public static List<Training__c> AllTrainings
    {
        get{
            if(AllTrainings == null)
            {
                AllTrainings = [SELECT Id, Name, TrainingLocation__c, Trainer__r.Name, StartDate__c, 
                                TrainingLocation__r.OfficeName__c, EndDate__c, 
                                CoTrainer__r.name, TrainingTrack__r.ShortName__c,
                                TrainingTrack__r.Color__c,
                                TrainingClass__c FROM Training__c ORDER BY Trainer__r.name, StartDate__c];
            }
            
            return AllTrainings;
        }
        set;
    }
    
    public static List<Training__c> currentTrainings
    {
        get{
            if(currentTrainings == null)
            {  
                currentTrainings = AllTrainings;
            }
            return currentTrainings;
        }
        set;
    }
    
    public static List<User> trainers {
        get{
            if(trainers == null){
                trainers =  [SELECT Name 
                             FROM User 
                             WHERE UserRole.Name = 'Trainer' OR UserRole.Name = 'CoTrainer'];
            }
            return trainers;
        }
        set;
    } 
    
    @AuraEnabled
    public static String[] getTrainingLocations()
    {
        String[] officeLocations = new String[]{};
            for(Training__c t : AllTrainings)
        {
            officeLocations.add(t.TrainingLocation__r.OfficeName__c);
        }
        return officeLocations;
    }
    
    @AuraEnabled
    public static String[] getTrainers()
    {
        String[]trainerNames;
        trainerNames = new String[]{};
            for(User u : trainers)
        {
            trainerNames.add(u.Name);
        }
        return trainerNames;
    }
    
    @AuraEnabled
    public static String wrapTrainingToJSON()
    {
        List<TrainingDataWrapper> trainerData = new List<TrainingDataWrapper>();
        System.debug('This is trainers: ' + trainers);
        System.debug('currentTrainings: ' + currentTrainings);
        
        for(Training__c t : currentTrainings){
            for(Integer i = 0; i < trainers.size(); i++)
            { 
                if(t.Trainer__r.name == trainers[i].name){
                    TrainingDataWrapper tdw = new TrainingDataWrapper();
                    tdw.x = t.StartDate__c;
                    tdw.x2 = t.EndDate__c;
                    tdw.y = i;
                    tdw.series = t.TrainingTrack__r.ShortName__c;
                    tdw.color = t.TrainingTrack__r.Color__c;
                    trainerData.add(tdw); 
                }
            }
        }
        
        return System.json.serialize(trainerData);
        
    }
    
    public class TrainingDataWrapper
    {
        @AuraEnabled
        public Integer y;
        @AuraEnabled
        public Date x;
        @AuraEnabled
        public Date x2;
        @AuraEnabled
        public String series;
        @AuraEnabled
        public String color;
    }
    
    @AuraEnabled
    public static String filterTrainingsByYearLocationQuarter(String[] location, Integer year, Integer quarter)
    {
        List<Training__c> NewTrainings = new List<Training__c>();
        List<Integer> monthList = new List<Integer>();        
        switch on(quarter)
        {
            when 2
            {
                monthList.add(01);
                monthList.add(02);
                monthList.add(03);
            }
            
            when 3
            {
                monthList.add(04);
                monthList.add(05);
                monthList.add(06);
            }
            
            when 4
            {
                monthList.add(07);
                monthList.add(08);
                monthList.add(09);
            }
            
            when 5
            {
                monthList.add(10);
                monthList.add(11);
                monthList.add(12);
            }
            
            when else
            {
                return null;
            }
        }
        Integer convertedYear = 0;
        
        switch on(year)
        {
            when 1
            {
                convertedYear = Date.today().year();
            }
            
            when 2 
            {
                convertedYear = Date.today().year() - 1;
            }
            
            when 3 
            {
                convertedYear = Date.today().year() - 2;
            }
            
            when else
            {
                return null;
            }
        }
        for(Training__c t : currentTrainings)
        {
            Integer trainingYear = t.StartDate__c.year();
            Integer trainingMonth = t.StartDate__c.month();
            
            for(String s : location)
            {
                if(t.TrainingLocation__r.OfficeName__c == s && convertedYear == trainingYear && monthList.contains(trainingMonth))
                {
                    NewTrainings.add(t);
                }
            }
        }
        currentTrainings = NewTrainings;
        String trainerData = wrapTrainingToJSON();
        return trainerData;
    }
    
    @AuraEnabled
    public static String filterTrainingsByYearLocation(String[] location, Integer year)
    {
        List<Training__c> NewTrainings = new List<Training__c>();
        Integer convertedYear = 0;
        
        switch on(year)
        {
            when 1
            {
                convertedYear = Date.today().year();
            }
            
            when 2 
            {
                convertedYear = Date.today().year() - 1;
            }
            
            when 3 
            {
                convertedYear = Date.today().year() - 2;
            }
            
            when else
            {
                return null;
            }
        }
        
        for(Training__c t : currentTrainings)
        {
            Integer trainingYear = t.StartDate__c.year();
            
            for(String s : Location)
            {
                System.debug('TrainingLocation__r: ' + t.TrainingLocation__r.OfficeName__c);
                System.debug('s: ' + s);
                System.debug('Year: ' + convertedYear);
                
                if(t.TrainingLocation__r.OfficeName__c == s && convertedYear == trainingYear )
                {
                    NewTrainings.add(t);
                }
            }
        }
        currentTrainings = NewTrainings;
        String trainerData = wrapTrainingToJSON();
        return trainerData;
    }
    
    
    @AuraEnabled
    public static String filterTrainingsByYearQuarter(Integer year, Integer quarter)
    {
        List<Integer> monthList = new List<Integer>(); 
        List<Training__c> NewTrainings = new List<Training__c>();
        Integer convertedYear = 0;
        
        switch on(year)
        {
            when 1
            {
                convertedYear = Date.today().year();
            }
            
            when 2 
            {
                convertedYear = Date.today().year() - 1;
            }
            
            when 3 
            {
                convertedYear = Date.today().year() - 2;
            }
            
            when else
            {
                return null;
            }
        }
        switch on(quarter)
        {
            when 2
            {
                monthList.add(01);
                monthList.add(02);
                monthList.add(03);
            }
            
            when 3
            {
                monthList.add(04);
                monthList.add(05);
                monthList.add(06);
            }
            
            when 4
            {
                monthList.add(07);
                monthList.add(08);
                monthList.add(09);
            }
            
            when 5
            {
                monthList.add(10);
                monthList.add(11);
                monthList.add(12);
            }
            
            when else
            {
                return null;
            }
        }
        for(Training__c t : currentTrainings)
        {
            Integer trainingYear = t.StartDate__c.year();
            Integer trainingMonth = t.StartDate__c.month();
            
            if(convertedYear == trainingYear && monthList.contains(trainingMonth))
            {
                NewTrainings.add(t);
            }
            
        }
        currentTrainings = NewTrainings;
        String trainerData = wrapTrainingToJSON();
        return trainerData;
    }
    
    @AuraEnabled
    public static String filterTrainingsByYear(Integer year)
    {
        List<Training__c> NewTrainings = new List<Training__c>();
        Integer convertedYear = 0;
        
        switch on(year)
        {
            when 1
            {
                convertedYear = Date.today().year();
            }
            
            when 2 
            {
                convertedYear = Date.today().year() - 1;
            }
            
            when 3 
            {
                convertedYear = Date.today().year() - 2;
            }
            
            when else
            {
                return null;
            }
        }
        
        for(Training__c t : currentTrainings)
        {
            Integer trainingYear = t.StartDate__c.year();
            
            if(convertedYear == trainingYear )
            {
                NewTrainings.add(t);
            }
        }
        currentTrainings = NewTrainings;
        String trainerData = wrapTrainingToJSON();
        return trainerData;
    }
    
}