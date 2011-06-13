jQuery.ajaxSetup({
    'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});

$.ajaxSetup ({
    cache: false
});

$(document).ready(function() {

    $("#more_raw_tweets").live('click', function( event ){
      $(this).replaceWith("<img id='nominate_spin' src='/images/loading.gif'/>");
      $.ajax({
        url: $(this).attr("href")
      });
      return false;
    });

    $("a.tweet_now").live('click', function( event ){
      $(this).replaceWith("<img id='nominate_spin' src='/images/loading.gif'/>");
      $.ajax({
        url: $(this).attr("href"),
        complete: function(){
            $(this).hide();
        }
      });
      return false;
    });
    

    $(".vote_link" ).live('click', function() {
        $(this).parent().find(".up_vote").unbind("click");
        $(this).parent().find(".up_vote").click(function(){ return false; });
        $(this).parent().find(".down_vote").unbind("click");
        $(this).parent().find(".down_vote").click(function(){ return false; });
        
        if ($(this).is('.up_vote')) {
            vote_element = $(this).parents("li").find(".win_votes");
            $(this).parents("li").find(".down_vote").unbind('click');
             $(this).parents("li").find(".down_vote").click(function(){ return false; });
        } else if ($(this).is('.down_vote')) {
            vote_element = $(this).parents("li").find(".loss_votes");
            $(this).parents("li").find(".up_vote").unbind('click');
            $(this).parents("li").find(".up_vote").click(function(){ return false; });
        }
        
        votes = parseInt( $(vote_element).html() );
        $(vote_element).html( votes +1 );

        $.ajax({
            url: '/tweet/vote',
            type: "POST",
            data: ({vote : $(this).attr('id')}),
            complete: function(data) {
            }

         });
        return false;

    });

    callTimeago();

    $(".twitter_cell").live({
        mouseenter: function() {
            $(this).find(".twitter_icon").animate({width: '57px'}, 300);
        },
        mouseleave: function(){
            $(this).find(".twitter_icon").animate({width: '18px'}, 300);
        }
    });

    $(".fb_cell").live({
        mouseenter: function() {
            $(this).find(".facebook_icon").animate({marginLeft:'0px', width: '57px'}, 300);
        }, mouseleave: function(){
            $(this).find(".facebook_icon").animate({marginLeft:'39px', width: '18px'}, 300);
        }
    });

        //Get all the LI from the #tabMenu UL
        $('#tabMenu > li').click(function(){

          //remove the selected class from all LI
          $('#tabMenu > li').removeClass('selected');

          //Reassign the LI
          $(this).addClass('selected');

          //Hide all the DIV in .boxBody
          $('.boxBody div.tweet_panel').slideUp();

          $('.show' + $('#tabMenu > li').index(this)).slideDown('3000');

        }).mouseover(function() {

          //Add and remove class, Personally I dont think this is the right way to do it, anyone please suggest
          $(this).addClass('mouseover');
          $(this).removeClass('mouseout2');

        }).mouseout(function() {

          //Add and remove class
          $(this).addClass('mouseout2');
          $(this).removeClass('mouseover');

        });

        //Mouseover with animate Effect for Category menu list
        $('.boxBody #category li').mouseover(function() {

          //Change background color and animate the padding
          $(this).css('backgroundColor','#888');
          $(this).children().animate({paddingLeft:"20px"}, {queue:false, duration:300});
        }).mouseout(function() {

          //Change background color and animate the padding
          $(this).css('backgroundColor','');
          $(this).children().animate({paddingLeft:"0"}, {queue:false, duration:300});
        });
    });


    function callTimeago(){
        $(".timeago").timeago();
    }


    function prepTweets(){
      $(".nominate_link").hide();

      $(".nominated_tweet .arrow").html("Submitted");

      $(".unselected_tweet").hover( function(){
        $(this).addClass('pretty-hover');
        $(this).css('cursor', 'pointer');
      }, function() {
        $(this).removeClass('pretty-hover');
      });

      $(".unselected_tweet").hover( function(){
        $(this).children(".raw_status_body").addClass('nominator_hover');
      }, function() {
        $(this).children(".raw_status_body").removeClass('nominator_hover');
      });

      $(".nominate_link").parents(".unselected_tweet").click( function(event){

        event.preventDefault();

        var nominate_link = $(this).find(".nominate_link:first");
        preSubmitTweet( this );
        var nominate_element = $(this);
        
        $("#dialog").html("Are you sure you want to submit: \"" + $(this).find(".text").html() + "\"?");
        $("#dialog").dialog({
            buttons: {
                'Submit': function() {
                    $.ajax({
                      url: $(nominate_link).attr("href"),
                      complete: function(data) {
                        prepTweets();
                        $(nominate_element).css('background', '');
                        $(nominate_element).css('color', 'grey');
                      }
                    });
                    $(this).dialog('close');
                },
                Cancel: function() {
                    $(nominate_element).css('background',"");
                    $(this).dialog('close');
                }
            }
        });
        $("#dialog").dialog("open");

        return false;
      });

    }

    function preSubmitTweet( element ){
      $(element).parent().css('cursor', '');
      $(element).parent().removeClass('unselected_tweet').removeClass('pretty-hover').addClass('nominated_tweet');
      $(element).removeClass('nominator_hover');
      $(element).css('background',"url('/images/loading.gif') no-repeat right top");
      $(element).parent().unbind();
    }

    function resetSubmit(){
        $("#loading_filter").hide();
        $("#submit_filter").show();
    }

var uservoiceOptions = {
  /* required */
  key: 'feedladder',
  host: 'feedladder.uservoice.com',
  forum: '80555',
  showTab: true,
  /* optional */
  alignment: 'right',
  background_color:'#06C',
  text_color: 'white',
  hover_color: '#f00',
  lang: 'en'
};

function _loadUserVoice() {
  var s = document.createElement('script');
  s.setAttribute('type', 'text/javascript');
  s.setAttribute('src', ("https:" == document.location.protocol ? "https://" : "http://") + "cdn.uservoice.com/javascripts/widgets/tab.js");
  document.getElementsByTagName('head')[0].appendChild(s);
}
_loadSuper = window.onload;
window.onload = (typeof window.onload != 'function') ? _loadUserVoice : function() { _loadSuper(); _loadUserVoice(); };