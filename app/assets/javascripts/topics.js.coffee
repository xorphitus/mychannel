initTopicTarget = (elem) ->
  $('#topic_target_text').toggle(elem.val() is 'free')

initTracAction = (elem) ->
  target = elem.closest('.row').next(':first')
  target.toggle(elem.find('option:selected').val() isnt 'youtube')

$('#topic_target_text').hide()
$('#topic_targets').find('input:radio').click ->
  initTopicTarget($(@))
.end().find('input:radio:checked').each ->
  initTopicTarget($(@))

$('.trac_action').change ->
  initTracAction($(@))
.each ->
  initTracAction($(@))

$('#trac_list').find('tr:last').addClass('info')