%{ for group, hosts in groups }
${group}:
   hosts:
%{ for ip in hosts }
     ${ip}:
%{ endfor ~}
%{ endfor ~}
