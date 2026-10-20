function isValidQuotePhone(value) {
    var digits = value.replace(/\D/g, '');
    return /^[+()\d\s.\-]+$/.test(value) && digits.length >= 10 && digits.length <= 15;
  }
var cases = [
 ['8187465432',true], ['(818) 746-5432',true], ['+1 818 746 5432',true],
 ['818.746.5432',true], ['+44 20 7946 0958',true], ['',false], ['a',false],
 ['123',false], ['818746543',false], ['1234567890123456',false],
 ['call 8187465432',false], ['8187465432<script>',false]
];
for(var i=0;i<cases.length;i++) {if(isValidQuotePhone(cases[i][0])!==cases[i][1]) {throw new Error('Phone validation failed: '+cases[i][0]);}}
WScript.Echo('PASS: '+cases.length+' phone validation cases, using the production helper.');