      $(document).ready(function(){
         $(".status_indicators").show(); //hidden by default

        $(".red_indicator").live({
            mouseenter: function () {
              $(this).removeClass("red_off");
              $(this).addClass("red_on");
              $(this).css('cursor', 'pointer');
            },
            mouseleave: function () {
                if (!$(this).hasClass("initial_lit")){
                  $(this).addClass("red_off");
                  $(this).removeClass("red_on");
                }
            }
        });

        $(".yellow_indicator").live({
            mouseenter:function () {
              $(this).removeClass("yellow_off");
              $(this).addClass("yellow_on");
              $(this).css('cursor', 'pointer');
            },
             mouseleave:function () {
                 if (!$(this).hasClass("initial_lit")){
                  $(this).addClass("yellow_off");
                  $(this).removeClass("yellow_on");
                 }
            }
        });

        $(".green_indicator").live({
            mouseenter:function () {
              $(this).removeClass("green_off");
              $(this).addClass("green_on");
              $(this).css('cursor', 'pointer');
            },
             mouseleave:function () {
                 if (!$(this).hasClass("initial_lit")){
                  $(this).addClass("green_off");
                  $(this).removeClass("green_on");
                 }
            }
        });

        $(".green_indicator" ).live("click",function() {
          change_status( $(this).parents("li"), 2 );
        });

        $(".yellow_indicator" ).live("click",function() {
          change_status( $(this).parents("li"), 1 );
        });

        $(".red_indicator" ).live("click",function() {
           change_status( $(this).parents("li"), 0 );
        });

      });


      function change_status( li_element, new_status ){

        $(li_element).find('.red_indicator').removeClass('initial_lit').removeClass('red_on').addClass('red_off').unbind();
        $(li_element).find('.yellow_indicator').removeClass('initial_lit').removeClass('yellow_on').addClass('yellow_off').unbind();
        $(li_element).find('.green_indicator').removeClass('initial_lit').removeClass('green_on').addClass('green_off').unbind();

        $.get(
            "/tweet/change_status",
            { quote_id: $(li_element).attr('id'), quote_status: new_status },
            function(data){
                if (new_status == 0){
                    $(li_element).slideUp();
                } else if (new_status ==1) {
                    $(li_element).find('.yellow_off').removeClass('yellow_off').addClass('yellow_on').addClass('initial_lit');
                    $(li_element).find(".green_off" ).click(function() {
                      change_status( $(this).parents("li"), 2 );
                    });

                    $(li_element).find(".red_off" ).click(function() {
                      change_status( $(this).parents("li"), 0 );
                    });
                } else if (new_status ==2){
                    $(li_element).find('.green_off').removeClass('green_off').addClass('green_on').addClass('initial_lit');
                    $(li_element).find(".yellow_off" ).click(function() {
                      change_status( $(this).parents("li"), 1 );
                    });

                    $(li_element).find(".red_off" ).click(function() {
                      change_status( $(this).parents("li"), 0 );
                    });
                }

            },
            "script"
        );
    }/**
 * Created by .
 * User: imack
 * Date: Jan 13, 2011
 * Time: 10:12:06 PM
 * To change this template use File | Settings | File Templates.
 */
