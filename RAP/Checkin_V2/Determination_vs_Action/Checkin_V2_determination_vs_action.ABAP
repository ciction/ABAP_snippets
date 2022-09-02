" A demonstration of the difference between a Determination and action (updating the same field)



CLASS lhc_zhr_m_check_in_v2 DEFINITION INHERITING FROM cl_abap_behavior_handler.
    PRIVATE SECTION.

      METHODS generatewindowsusername FOR DETERMINE ON MODIFY
        IMPORTING keys FOR zhr_m_check_in_v2~generatewindowsusername.
      METHODS generateWindowsUserName_act FOR MODIFY
        IMPORTING keys FOR ACTION zhr_m_check_in_v2~generateWindowsUserName_act RESULT result.
  
  ENDCLASS.
  
  CLASS lhc_zhr_m_check_in_v2 IMPLEMENTATION.
    "Generate a WindowsUser ID via Determination (when first and last name are saved)

    "Read the input fields we need from our entity
    METHOD generateWindowsUserName.
      READ ENTITIES OF zhr_m_check_in_v2 IN LOCAL MODE
           ENTITY zhr_m_check_in_v2
           FIELDS (
                    FirstName
                    LastName
                  )
           WITH CORRESPONDING #( keys )
           RESULT DATA(lt_checkin).
  
      "Modify the entities
      MODIFY ENTITIES OF zhr_m_check_in_v2 IN LOCAL MODE
             ENTITY zhr_m_check_in_v2
        UPDATE SET FIELDS WITH VALUE #(  FOR checkin IN lt_checkin    WHERE (
                                                FirstName IS NOT INITIAL AND
                                                LastName  IS NOT INITIAL )
                             (  %key        = checkin-%key
                                %is_draft   = checkin-%is_draft
                                WindowsUser = zcl_hr_chin_win_id_gen=>get_instance( )->generate(
                                                 EXPORTING
                                                 iv_first_name   = CONV #( checkin-FirstName )
                                                 iv_last_name    = CONV #( checkin-LastName  )  )
                                %control = VALUE #( WindowsUser = if_abap_behv=>mk-on )
                             ) )
      REPORTED DATA(modified_Checkins).
  
      "Report what has been modified
      reported = CORRESPONDING #(  DEEP modified_Checkins ).
    ENDMETHOD.
  
  
  
    METHOD generateWindowsUserName_act.
      "Generate a WindowsUser ID via a custom action button (more like function import)
  
      "update status
      MODIFY ENTITIES OF zhr_m_check_in_v2 IN LOCAL MODE
        ENTITY zhr_m_check_in_v2
          UPDATE FIELDS ( WindowsUser )
          WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                          WindowsUser = '' ) ). "Complete
  
      "read changed data for action result
      READ ENTITIES OF zhr_m_check_in_v2 IN LOCAL MODE
        ENTITY zhr_m_check_in_v2
          ALL FIELDS WITH
          CORRESPONDING #( keys )
          RESULT DATA(updated_checkins).
  
      result = VALUE #( FOR checkin IN updated_checkins ( %tky = checkin-%tky
                                                          %param = checkin ) ).
  
    ENDMETHOD.
  
  ENDCLASS.