/* Comando para criar um esquema só quando não existir aula_clinica no banco*/
CREATE SCHEMA IF NOT EXISTS aula_clinica; 

create table if not exists aula_clinica.paciente (
  id_paciente bigint generated always as identity primary key,
  nome varchar (120) not null, 
  cpf char(14) not null unique,
  data_nascimento date not null 
);

create table if not exists aula_clinica.medico (
  id_medico  bigint generated always as identity primary key,
  nome varchar (120) not null,
  crm varchar (20) not null unique
);

create table if not exists aula_clinica.especialidade (
  id_especialidade bigint generated always as identity primary key,
  nome varchar (80) not null unique
); 

/*tabelas dependentes*/

create table if not exists aula_clinica.telefone_paciente (
  id_telefone bigint generated always as identity primary key,
  id_paciente bigint not null,
  numero varchar (20) not null,
  /*O comando constraint serve para não permitir que dados inválidos, incompletos ou duplicados sejam inseridos ou alterados*/
  constraint fk_telefone_paciente foreign key (id_paciente)
  /*o comando on delete cascade serva para excluir os registros relacionados (filhos) em uma tabela quando o registro principal (pai) é apagado*/
  references aula_clinica.paciente (id_paciente) on delete cascade 

);

create table if not exists aula_clinica.medico_especialidade (
  id_medico bigint not null,
  id_especialidade bigint not null,
  data_certificacao date,
  primary key (id_medico, id_especialidade),
  foreign key (id_medico) references aula_clinica.medico(id_medico),
  foreign key (id_especialidade) references aula_clinica.especialidade(id_especialidade)
);

create table if not exists aula_clinica.consulta (
 id_consulta bigint generated always as identity primary key,
 id_paciente bigint not null,
 id_medico BIGINT not null,
 id_especialidade BIGINT not null,
 data_hora TIMESTAMPTZ not null,
 status VARCHAR(20) not null default 'AGENDADA',
 diagnostico TEXT,
 constraint ck_consulta_status check (status IN ('AGENDADA','REALIZADA','CANCELADA')),
 constraint fk_consulta_paciente foreign KEY (id_paciente)
 references aula_clinica.paciente(id_paciente) ON DELETE RESTRICT,
 constraint fk_consulta_medico_especialidade foreign key (id_medico, id_especialidade)
 references aula_clinica.medico_especialidade(id_medico, id_especialidade)
);

SELECT table_name FROM information_schema.tables WHERE table_schema = 'aula_clinica' ORDER BY
table_name;


/*Fazendo a inserção dos dados*/

insert into aula_clinica.paciente (nome, cpf, data_nascimento) values
('Ana Lima','11122233344','1992-05-14'),
('Bruno Rocha','22233344455','1985-09-20'),
('Carla Nunes','33344455566','2001-02-03'),
('Diego Alves','44455566677','1978-11-30'),
('Elisa Ramos','55566677788','1996-07-18');
insert into aula_clinica.medico (nome, crm) values
('Marina Costa','CRM-DF-1001'),('Paulo Reis','CRM-DF-1002'),
('Renata Dias','CRM-DF-1003'),('Sergio Luz','CRM-DF-1004');
insert into aula_clinica.especialidade (nome) values
('Cardiologia'),('Dermatologia'),('Clínica Geral');


/*O comando order by serve para ordernar resultados de um select com uma ou mais colunas*/
select *from  aula_clinica.paciente order by id_paciente;
select *from  aula_clinica.medico order by id_medico;
select *from  aula_clinica.especialidade order by id_especialidade;

INSERT INTO aula_clinica.medico_especialidade
(id_medico, id_especialidade, data_certificacao) VALUES
(1,1,'2018-12-10'),(1,3,'2015-06-20'),(2,2,'2019-03-15'),
(3,3,'2020-08-01'),(4,1,'2016-04-12');
INSERT INTO aula_clinica.telefone_paciente (id_paciente, numero) VALUES
(1,'61999990001'),(1,'6133330001'),(2,'61999990002'),
(3,'61999990003'),(4,'61999990004'),(5,'61999990005');

INSERT INTO aula_clinica.consulta
(id_paciente,id_medico,id_especialidade,data_hora,status,diagnostico) VALUES
(1,1,1,'2026-11-10 09:00-03','REALIZADA','Avaliação cardiovascular'),
(2,2,2,'2026-11-10 10:00-03','AGENDADA',NULL),
(3,3,3,'2026-11-11 08:30-03','REALIZADA','Quadro viral leve'),
(4,4,1,'2026-11-11 11:00-03','AGENDADA',NULL),
(5,1,3,'2026-11-12 14:00-03','CANCELADA',NULL),
(1,1,3,'2026-11-13 15:30-03','AGENDADA',NULL);


select * from  aula_clinica.consulta where id_consulta =2; 
update aula_clinica.consulta
set status = 'REALIZADA', diagnostico = 'Consulta de acompanhamento'
where id_consulta = 2; 
select *from aula_clinica.consulta where id_consulta =2;

delete from aula_clinica.consulta where status = 'CANCELADA' and id_consulta = 5 returning *; 

/*CPF duplicado*/
/*O erro acontece aqui porque estamos tentando inserir um novo registro com um cpf já existente. Esse erro viola o UNIQUE que garante que cada registro tenha seu cpf unico*/
insert into aula_clinica.paciente (nome, cpf, data_nascimento)
values ('Teste Duplicado','11122233344','2000-01-01');


-- status fora do domínio
/*O erro acontece porque esta sendo inserido uma consulta com um status que não é esperado. Os status só aceitam AGENDADA, REALIZADA e CANCELADA*/
insert into aula_clinica.consulta
(id_paciente,id_medico,id_especialidade,data_hora,status)
values (1,1,1,now(),'EM ESPERA');


-- médico sem a especialidade informada
/*O erro ocorre porque a consulta esta vinculada a um médico e a uma especialidadde  que o medico não esta habilitado para atender*/
insert into aula_clinica.consulta
(id_paciente,id_medico,id_especialidade,data_hora,status)
values (1,2,1,now(),'AGENDADA');

select id_paciente, nome, cpf from aula_clinica.paciente order by nome;

select p.nome AS paciente, m.nome AS medico, e.nome AS especialidade,
 c.data_hora, c.status
from aula_clinica.consulta c
join aula_clinica.paciente p ON p.id_paciente = c.id_paciente
join aula_clinica.medico m ON m.id_medico = c.id_medico
join aula_clinica.especialidade e ON e.id_especialidade = c.id_especialidade
order BY c.data_hora;


select e.nome, COUNT(*) AS total_consultas
from aula_clinica.consulta c
join aula_clinica.especialidade e ON e.id_especialidade = c.id_especialidade
group BY e.nome
order BY total_consultas DESC, e.nome;

select * from aula_clinica.consulta where status = 'REALIZADA';
