function rating_types = call_ratingtypes_cl
%call_ratingtypes
%This function can call dictionary of rating types and prompts.
%its output is rating_types, and it has 3 substructure.
%rating_types.prompts_ex : prompts for explanation
%rating_types.alltypes : dictionary of rating types
%rating_types.prompts : prompts for each rating type


% ********** IMPORTANT NOTE **********
% YOU CAN ADD TYPES AND PROMPTS HERE. "cont_" AND "overall_" ARE IMPORTANT.
% * CRUCIAL: THE ORDER BETWEEN alltypes AND prompts SHOULD BE THE SAME.*


temp_rating_types_cl = {
    'overall_alertness', '방금 세션동안 얼마나 졸리셨나요, 혹은 얼마나 정신이 또렷했나요?'; ...
    'overall_relaxed', '지금 얼마나 편안하신가요?';...
    'overall_attention', '방금 세션동안 과제에 얼마나 집중하셨나요?'; ...
    'overall_int_weak', '방금 세션동안 통증이 가장 약할 때 얼마나 약했나요?'; ...
    'overall_int_strong', '방금 세션동안 통증이 가장 강할 때 얼마나 강했나요?'};
rating_types.alltypes = temp_rating_types_cl(:,1);
rating_types.prompts = temp_rating_types_cl(:,2);


% rating_types_pls.postallstims = {'high-cue', 'high-nocue', 'low-cue', 'low-nocue'};
rating_types.postalltypes{1} = ...
    {'overall_relaxed', ...
    'overall_attention', ...
    'overall_alertness', ...
    'overall_int_weak', ...
    'overall_int_strong'};

end
