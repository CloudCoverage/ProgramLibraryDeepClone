public with sharing class DoubleMe {

    private static Integer daysToAdd;
    private static Id sessionId;

    @InvocableMethod(label='Double Me' description='Provide a collection of Course Session Options to clone')
    public static List<Result> doubleThisCollection(List<Request> lstRequests) {
        List<Result> lstResults = new List<Result>();

        List<TREX1__Course_Session_Option__c> lstCSOs = lstRequests.get(0).lstCSOs;
        sessionId = lstRequests.get(0).sessionId;
        daysToAdd = lstRequests.get(0).daysToAdd != null ? lstRequests.get(0).daysToAdd : 0;

        Set<Id> setCourseOptionIds = new Set<Id>();
        Set<Id> setCourseSessionIds = new Set<Id>();
        // Create sets of ids for queries
        for (TREX1__Course_Session_Option__c cso : lstCSOs) {
            setCourseOptionIds.add(cso.TREX1__Course_Option__c);
            setCourseSessionIds.add(cso.TREX1__Course_Session__c);
        }

        // Get map of records with only fields to clone
        Map<Id, TREX1__Course_Session__c> mapCourseSessions = getCourseSessionMap(setCourseSessionIds);
        Map<Id, TREX1__Course_Option__c> mapCourseOptions = getCourseOptionMap(setCourseOptionIds);
        // Create maps of cloned records and insert them
        Map<Id, TREX1__Course_Session__c> mapOldCourseSessionIdToClone = getClonedCourseSessionMap(mapCourseSessions);
        if (!mapOldCourseSessionIdToClone.isEmpty()) {
            insert mapOldCourseSessionIdToClone.values();
        }
        Map<Id, TREX1__Course_Option__c> mapOldCourseOptionIdToClone = getClonedCourseOptionMap(mapCourseOptions);
        if (!mapOldCourseOptionIdToClone.isEmpty()) {
            insert mapOldCourseOptionIdToClone.values();
        }

        // Create CSOs for each in request, pointing to cloned parent records
        List<TREX1__Course_Session_Option__c> lstClonedCSOs = new List<TREX1__Course_Session_Option__c>();
        for (TREX1__Course_Session_Option__c cso : lstCSOs) {
            lstClonedCSOs.add(
                new TREX1__Course_Session_Option__c(
                    TREX1__Course_Session__c   = mapOldCourseSessionIdToClone.get(cso.TREX1__Course_Session__c).Id,
                    TREX1__Course_Option__c    = mapOldCourseOptionIdToClone.get(cso.TREX1__Course_Option__c).Id,
                    TREX1__Option_Available__c = cso.TREX1__Option_Available__c,
                    TREX1__Available_Online__c = cso.TREX1__Available_Online__c
                )
            );
        }
        if (!lstClonedCSOs.isEmpty()) {
            insert lstClonedCSOs;
        }

        Result result = new Result();
        result.lstClonedCSOs = lstClonedCSOs;
        result.lstClonedCourseSessions = mapOldCourseSessionIdToClone.values();
        result.lstClonedCourseOptions = mapOldCourseOptionIdToClone.values();
        lstResults.add(result);
        return lstResults;

    }

    private static Map<Id, TREX1__Course_Session__c> getClonedCourseSessionMap(
        Map<Id, TREX1__Course_Session__c> mapCourseSessions
    ) {
        Map<Id, TREX1__Course_Session__c> mapOldCourseSessionIdToClone = new Map<Id, TREX1__Course_Session__c>();
        for (TREX1__Course_Session__c cs : mapCourseSessions.values()) {
            TREX1__Course_Session__c clonedCourseSession = cs.clone(false, false, false, false);
            updateCourseSessionDates(clonedCourseSession, daysToAdd);
            clonedCourseSession.TREX1__Session__c = sessionId;
            mapOldCourseSessionIdToClone.put(cs.Id, clonedCourseSession);
        }
        return mapOldCourseSessionIdToClone;
    }

    private static Map<Id, TREX1__Course_Option__c> getClonedCourseOptionMap(
        Map<Id, TREX1__Course_Option__c> mapCourseOptions
    ) {
        Map<Id, TREX1__Course_Option__c> mapOldCourseOptionIdToClone = new Map<Id, TREX1__Course_Option__c>();
        for (TREX1__Course_Option__c co : mapCourseOptions.values()) {
            TREX1__Course_Option__c clonedCourseOption = co.clone(false, false, false, false);
            updateCourseOptionDates(clonedCourseOption, daysToAdd);
            mapOldCourseOptionIdToClone.put(co.Id, clonedCourseOption);
        }
        return mapOldCourseOptionIdToClone;
    }

    private static void updateCourseSessionDates(TREX1__Course_Session__c cs, Integer daysToAdd) {
        cs.TREX1__Available_Online_From__c = cs.TREX1__Available_Online_From__c != null ? cs.TREX1__Available_Online_From__c + daysToAdd : null;
        cs.TREX1__Available_Online_To__c = cs.TREX1__Available_Online_To__c != null ? cs.TREX1__Available_Online_To__c + daysToAdd : null;
    } 

    private static void updateCourseOptionDates(TREX1__Course_Option__c co, Integer daysToAdd) {
        co.TREX1__Start_Date__c = co.TREX1__Start_Date__c != null ? co.TREX1__Start_Date__c + daysToAdd : null;
        co.TREX1__End_Date__c = co.TREX1__End_Date__c != null ? co.TREX1__End_Date__c + daysToAdd : null;
        co.TREX1__Register_From_Date__c = co.TREX1__Register_From_Date__c != null ? co.TREX1__Register_From_Date__c + daysToAdd : null;
        co.TREX1__Register_To_Date__c = co.TREX1__Register_From_Date__c != null ? co.TREX1__Register_From_Date__c + daysToAdd : null;
        co.TREX1__Register_Online_From_Date__c = co.TREX1__Register_Online_From_Date__c != null ? co.TREX1__Register_Online_From_Date__c + daysToAdd : null;
        co.TREX1__Register_Online_To_Date__c = co.TREX1__Register_Online_To_Date__c != null ? co.TREX1__Register_Online_To_Date__c + daysToAdd : null;
        co.TREX1__Early_Register_From_Date__c = co.TREX1__Early_Register_From_Date__c != null ? co.TREX1__Early_Register_From_Date__c + daysToAdd : null;
        co.TREX1__Early_Register_To_Date__c = co.TREX1__Early_Register_To_Date__c != null ? co.TREX1__Early_Register_To_Date__c + daysToAdd : null;
        co.TREX1__Early_Register_Online_From_Date__c = co.TREX1__Early_Register_Online_From_Date__c != null ? co.TREX1__Early_Register_Online_From_Date__c + daysToAdd : null;
        co.TREX1__Early_Register_Online_To_Date__c = co.TREX1__Early_Register_Online_To_Date__c != null ? co.TREX1__Early_Register_Online_To_Date__c + daysToAdd : null;
    } 

    private static Map<Id, TREX1__Course_Session__c> getCourseSessionMap(Set<Id> setCourseSessionIds) {
        return new Map<Id, TREX1__Course_Session__c>([
            SELECT Id, Name, Location__c, TREX1__Available__c, TREX1__Available_Online__c, TREX1__Available_Online_From__c, 
                   TREX1__Available_Online_To__c, TREX1__Code__c, TREX1__Course__c, TREX1__Description__c, TREX1__Expiry_Extension_Seconds__c,
                   TREX1__External_Alert__c, TREX1__Free_Membership_End_Date__c, TREX1__Free_Membership_Start_Date__c, TREX1__Free_Membership_Type__c, 
                   TREX1__Initial_Seconds_To_Expiry__c, TREX1__Internal_Alert__c, TREX1__Max_Expiry_Seconds__c, TREX1__Num_Classroom_Assignments__c,
                   TREX1__Num_Option_Entitlements__c, TREX1__Product__c, TREX1__Required_of_Employees_10_Registrants__c, TREX1__Reservation_Expiry_Seconds__c,
                   TREX1__Rich_Description__c, TREX1__Session__c, TREX1__Status__c, TREX1__Supervisor__c, TREX1__Supervisor_Email__c,
                   TREX1__Transfer_Fee__c, TREX1__Transfer_GL_Account__c, TREX1__Transfer_in_within_Program__c, TREX1__Transfer_out_within_Program__c, 
                   TREX1__Waitlist_Message__c, TREX1__Withdrawal_Days__c, TREX1__Withdrawal_Fee__c, TREX1__Withdrawal_GL_Account__c, TREX1__Withdrawal_Policy__c
              FROM TREX1__Course_Session__c 
             WHERE Id IN :setCourseSessionIds
        ]);
    }

    private static Map<Id, TREX1__Course_Option__c> getCourseOptionMap(Set<Id> setCourseOptionIds) {
        return new Map<Id, TREX1__Course_Option__c>([
            SELECT Id, Name, Day_of_Week_Code__c, TREX1__Age_as_of_date__c, TREX1__Age_Max__c, TREX1__Age_Min__c, 
                   TREX1__Attendance_Group__c, TREX1__Available__c, TREX1__Available_Online__c, TREX1__Capacity__c, 
                   TREX1__Code__c, TREX1__Day_of_Week__c, TREX1__Description__c, TREX1__Scanning_Location__c, 
                   TREX1__Display_Number_of_Classes__c, TREX1__Early_Register__c, TREX1__Early_Register_From_Date__c,
                   TREX1__Early_Register_From_Time__c, TREX1__Early_Register_Online__c, TREX1__Early_Register_Online_From_Date__c,
                   TREX1__Early_Register_Online_From_Time__c, TREX1__Early_Register_Online_To_Date__c, 
                   TREX1__Early_Register_Online_To_Time__c, TREX1__Early_Register_To_Date__c, TREX1__Early_Register_To_Time__c,
                   TREX1__Enable_Automated_Waitlist__c, TREX1__Enable_Calendar_Booking_Download__c, TREX1__Enable_Reservation__c,
                   TREX1__End_Date__c, TREX1__End_Time__c, TREX1__Grade_Range__c, TREX1__Instructor__c, TREX1__Location__c,
                   TREX1__Number_of_Classes__c, TREX1__Overbooking_Capacity__c, TREX1__Product__c, TREX1__Register_From_Date__c,
                   TREX1__Register_From_Time__c, TREX1__Register_Online_From_Date__c, TREX1__Register_Online_From_Time__c,
                   TREX1__Register_Online_To_Date__c, TREX1__Register_Online_To_Time__c, TREX1__Register_To_Date__c, 
                   TREX1__Register_To_Time__c, TREX1__Setup_Notes__c, TREX1__Setup_Time_Required__c, TREX1__Show_Age_Range__c,
                   TREX1__Show_Capacity_Online__c, TREX1__Show_Cost__c, TREX1__Show_Days__c, TREX1__Show_Grade_Range__c, 
                   TREX1__Show_Instructor__c, TREX1__Show_Location__c, TREX1__Show_Time_Window__c, TREX1__Show_Watlist_Capacity__c,
                   TREX1__Special_Instructions__c, TREX1__Start_Date__c, TREX1__Start_Time__c, TREX1__Status__c, 
                   TREX1__Tear_Down_Notes__c, TREX1__Tear_Down_Time_Required__c, TREX1__Transfer_in_within_Program__c,
                   TREX1__Transfer_out_within_Program__c, TREX1__Type__c, TREX1__Unlimited_Capacity__c, 
                   TREX1__Unlimited_Overbooking_Capacity__c, TREX1__Unlimited_Waitlist_Capacity__c, 
                   TREX1__Unnamed_Group_Reg_Max_Tickets__c, TREX1__Unnamed_Group_Reg_Min_Tickets__c,
                   TREX1__Unnamed_Group_Registration__c, TREX1__Waitlist_Capacity__c, TREX1__Waitlist_Message__c,
                   TREX1__Waitlist_Pending_Confirmation_Total__c, TREX1__Waitlist_Total__c
              FROM TREX1__Course_Option__c 
             WHERE Id IN :setCourseOptionIds
        ]);
    }

    public class Request {
        @InvocableVariable(required=true description='Original Course Session Options')
        public List<TREX1__Course_Session_Option__c> lstCSOs;
        @InvocableVariable(required=true description='Target Session')
        public Id sessionId;
        @InvocableVariable(description='Days to Add')
        public Integer daysToAdd;
    }

    public class Result {
        @InvocableVariable(description='Cloned Course Sessions')
        public List<TREX1__Course_Session__c> lstClonedCourseSessions;
        @InvocableVariable(description='Cloned Course Options')
        public List<TREX1__Course_Option__c> lstClonedCourseOptions;
        @InvocableVariable(description='Cloned Course Session Options')
        public List<TREX1__Course_Session_Option__c> lstClonedCSOs;
    }

}