CREATE DATABASE vendas; 
USE vendas;
 
show tables;
 
CREATE TABLE cliente (
  id_cliente    INT AUTO_INCREMENT PRIMARY KEY,
  nome          VARCHAR(150) NOT NULL,
  cpf_cnpj      VARCHAR(18)  NOT NULL,
  email         VARCHAR(100) NULL,
  telefone      VARCHAR(20)  NULL,
  data_cadastro DATE         NOT NULL,
  status        VARCHAR(10)  NOT NULL DEFAULT 'ativo',
  CONSTRAINT uq_cliente_cpf_cnpj UNIQUE (cpf_cnpj),
  CONSTRAINT ck_cliente_email  CHECK (email IS NULL OR email REGEXP '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$'),
  CONSTRAINT ck_cliente_status CHECK (status IN ('ativo', 'inativo'))
);
 
CREATE TABLE vendedor (
  id_vendedor INT AUTO_INCREMENT PRIMARY KEY,
  nome        VARCHAR(150) NOT NULL,
  email       VARCHAR(100) NULL,
  telefone    VARCHAR(20)  NULL
);
 
CREATE TABLE fornecedor (
  id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
  razao_social  VARCHAR(150) NOT NULL,
  cnpj          CHAR(18)     NOT NULL,
  email         VARCHAR(100) NULL,
  telefone      VARCHAR(20)  NULL,
  CONSTRAINT uq_fornecedor_cnpj UNIQUE (cnpj)
);
 
CREATE TABLE categoria (
  id_categoria   INT AUTO_INCREMENT PRIMARY KEY,
  nome_categoria VARCHAR(100) NOT NULL,
  descricao      VARCHAR(255) NULL
);
 
CREATE TABLE produto (
  id_produto    INT AUTO_INCREMENT PRIMARY KEY,
  nome          VARCHAR(150)  NOT NULL,
  descricao     VARCHAR(255)  NOT NULL,
  preco         DECIMAL(10,2) NOT NULL,
  estoque       INT           NOT NULL DEFAULT 0,
  id_categoria  INT           NOT NULL,
  id_fornecedor INT           NOT NULL,
  CONSTRAINT ck_produto_preco   CHECK (preco > 0),
  CONSTRAINT ck_produto_estoque CHECK (estoque >= 0),
  CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria (id_categoria) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_produto_fornecedor FOREIGN KEY (id_fornecedor)
    REFERENCES fornecedor (id_fornecedor) ON UPDATE CASCADE ON DELETE RESTRICT
);
 
CREATE TABLE ordem (
  id_ordem    INT AUTO_INCREMENT PRIMARY KEY,
  data_ordem  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valor_total DECIMAL(12,2) NOT NULL DEFAULT 0,
  status      VARCHAR(20)   NOT NULL DEFAULT 'Aberto',
  id_cliente  INT           NOT NULL,
  id_vendedor INT           NOT NULL,
  CONSTRAINT ck_ordem_valor  CHECK (valor_total >= 0),
  CONSTRAINT ck_ordem_status CHECK (status IN ('Aberto', 'Pago', 'Cancelado', 'Finalizado')),
  CONSTRAINT fk_ordem_cliente FOREIGN KEY (id_cliente)
  
  
  
    REFERENCES cliente (id_cliente) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_ordem_vendedor FOREIGN KEY (id_vendedor)
    REFERENCES vendedor (id_vendedor) ON UPDATE CASCADE ON DELETE RESTRICT
);
 
CREATE TABLE item_pedido (
  id_item        INT AUTO_INCREMENT PRIMARY KEY,
  quantidade     INT           NOT NULL,
  valor_unitario DECIMAL(10,2) NOT NULL,
  id_ordem       INT           NOT NULL,
  id_produto     INT           NOT NULL,
  CONSTRAINT ck_item_quantidade CHECK (quantidade > 0),
  CONSTRAINT ck_item_valor      CHECK (valor_unitario > 0),
  CONSTRAINT fk_item_ordem FOREIGN KEY (id_ordem)
    REFERENCES ordem (id_ordem) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_item_produto FOREIGN KEY (id_produto)
    REFERENCES produto (id_produto) ON UPDATE CASCADE ON DELETE RESTRICT
);
 
CREATE TABLE pagamento (
  id_pagamento    INT AUTO_INCREMENT PRIMARY KEY,
  data_pagamento  DATE          NOT NULL,
  valor_pago      DECIMAL(12,2) NOT NULL,
  forma_pagamento VARCHAR(20)   NOT NULL,
  id_ordem        INT           NOT NULL,
  CONSTRAINT uq_pagamento_ordem UNIQUE (id_ordem),
  CONSTRAINT ck_pagamento_valor CHECK (valor_pago > 0),
  CONSTRAINT ck_pagamento_forma CHECK (forma_pagamento IN ('Dinheiro', 'PIX', 'Cartão', 'Boleto')),
  CONSTRAINT fk_pagamento_ordem FOREIGN KEY (id_ordem)
    REFERENCES ordem (id_ordem) ON UPDATE CASCADE ON DELETE RESTRICT
);

 Create view vw_cliente 
as select * 
from cliente 
where status in ('ativo','inativo');


create view vw_categoria 
as select *
from categoria 
where id_categoria between 1 and 20;

CREATE VIEW vw_item_pedido_por_quantidade AS
SELECT * 
FROM item_pedido 
WHERE quantidade IN (1, 2, 3)
ORDER BY quantidade DESC;

CREATE OR REPLACE VIEW vw_pagamento AS 
SELECT * 
FROM pagamento
WHERE forma_pagamento IN ('pix', 'cartão', 'boleto', 'dinheiro');


 -- ================= PROCEDURES ==================  
DELIMITER //

CREATE PROCEDURE AnalisarPagamentos(IN p_forma_pagamento VARCHAR(50))
BEGIN
   
    SELECT 
        MAX(valor_pago) AS maior_pagamento, 
        MIN(valor_pago) AS menor_pagamento 
    FROM pagamento;

    
    SELECT * 
    FROM vw_pagamento 
    WHERE LOWER(forma_pagamento) = LOWER(p_forma_pagamento);
END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE CalcularFaturamentoItem(IN p_id_item INT)
BEGIN
    SELECT sum(quantidade * valor_unitario) AS faturamento_total 
    FROM item_pedido 
    WHERE id_item = p_id_item;
END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE BuscarClientePorStatus (IN p_status varchar (50))
BEGIN
    SELECT *
    FROM vw_cliente 
    WHERE status  = p_status;
END //

DELIMITER ;

-- ================= DADOS =================

-- Clientes (11)
INSERT INTO cliente (nome, cpf_cnpj, email, telefone, data_cadastro, status) VALUES
('Lucas Andrade','421.558.920-04','lucas.andrade@testmail.com','(11) 99832-4410','2026-10-12','ativo'),
('Mariana Costa','128.447.660-80','mariana.costa@exemplo.com','(21) 99711-2034','2026-09-28','inativo'),
('João Henrique Ramos','12.345.678/0001-55','joao.ramos@sample.com','(31) 98820-7741','2026-10-01','ativo'),
('Ana Paula Ferreira','309.772.510-09','ana.ferreira@fakemail.com','(41) 99644-8820','2026-10-25','inativo'),
('Ricardo Monteiro','557.901.330-60','ricardo.monteiro@demo.com','(51) 99120-3308','2026-10-18','inativo'),
('Camila Duarte','45.987.321/0001-12','camila.duarte@empresa-test.com','(62) 99455-1022','2026-10-05','ativo'),
('Felipe Barbosa','210.998.440-33','felipe.barbosa@mockmail.com','(71) 99912-7740','2026-09-30','inativo'),
('Juliana Martins','034.882.700-10','juliana.martins@teste.com','(81) 99500-6611','2026-10-22','inativo'),
('Bruno Almeida','33.221.900/0001-77','bruno.almeida@placeholder.com','(85) 99821-4409','2026-10-14','inativo'),
('Patrícia Gomes','501.772.990-02','patricia.gomes@fakeid.com','(91) 99210-5588','2026-10-27','inativo'),
('Dimitri Mohhamed','011.006.200-19','explosaopatriota@fakeid.com','(22) 71311-9920','2026-09-30','inativo');
 
-- Vendedores (5)
INSERT INTO vendedor (nome, email, telefone) VALUES
('Fernando Albert Wesker','rezendeevil@gmail.com','(73) 95415-67'),
('Lionel Messi','Lionel.messi@gmail.com','(51) 98765-4321'),
('Roberto Gil','Robertogil@gmail.com','(51) 12345-6789'),
('Silvio Santos do CS','contersantos@gmail.com','(11) 3687-3000'),
('Cristiano Ronaldo','cristiano.ronaldo.official@gmail.com','(68) 99720-4489');
 
-- Fornecedores (5) 
INSERT INTO fornecedor (razao_social, cnpj, email, telefone) VALUES
('Tony Stark','33.221.900/0001-78','t.stark@starkindustries.com','+1 212 555 0198'),
('Silvestre estalone','12.900.450/0001-77','sylvester.stallone@nbcuni.com','(54) 3857-2233'),
('Monark','90.242.525/0001-26','monark.paixao@gmail.com','(47) 98877-3702'),
('Tiago Grilo Magalhães','62.478.817/0001-27','tiago.magalhaes@geradornv.com.br','(51) 97227-5449'),
('Milena Agatha da Paz','57.178.602/0001-50','milena_dapaz@dyna.com.br','(98) 2895-2892');
 
-- Categorias (5)
INSERT INTO categoria (nome_categoria, descricao) VALUES
('Computadores','Notebooks e desktops'),
('Smartphones','Celulares e tablets'),
('Periféricos','Mouses, teclados, fones e acessórios'),
('Monitores e Imagem','Monitores, webcams e impressoras'),
('Armazenamento e Redes','SSDs, HDs, memórias e roteadores');
 

INSERT INTO produto (id_produto, nome, descricao, preco, estoque, id_categoria, id_fornecedor) VALUES
(1, 'Notebook Gamer 15', 'Notebook 16GB RAM, SSD 512GB', 4899.00, 9, 1, 1),
(2, 'Notebook Office 14', 'Notebook 8GB RAM, SSD 256GB', 2799.00, 23, 1, 2),
(3, 'Smartphone X10', 'Smartphone 128GB, tela 6.5', 1899.00, 26, 2, 3),
(4, 'Smartphone Lite', 'Smartphone 64GB, tela 6.1', 999.00, 29, 2, 4),
(5, 'Fone Bluetooth Pro', 'Fone sem fio com cancelamento de ruído', 349.90, 32, 3, 5),
(6, 'Fone com Fio', 'Fone intra-auricular P2', 39.90, 35, 3, 1),
(7, 'Mouse Gamer RGB', 'Mouse 12000 DPI', 129.90, 38, 3, 2),
(8, 'Teclado Mecânico', 'Teclado mecânico switch azul', 279.90, 41, 3, 3),
(9, 'Monitor 24 Full HD', 'Monitor LED 24 polegadas', 849.00, 44, 4, 4),
(10, 'Monitor 27 144Hz', 'Monitor gamer 27 polegadas', 1649.00, 47, 4, 5),
(11, 'Webcam Full HD', 'Webcam 1080p com microfone', 199.90, 50, 4, 1),
(12, 'Impressora Laser', 'Impressora laser monocromática', 1199.00, 53, 4, 2),
(13, 'SSD 1TB NVMe', 'SSD NVMe 1TB leitura 3500MB/s', 489.00, 56, 5, 3),
(14, 'HD Externo 2TB', 'HD portátil USB 3.0', 429.00, 59, 5, 4),
(15, 'Pen Drive 64GB', 'Pen drive USB 3.0', 44.90, 62, 5, 5),
(16, 'Cartão de Memória 128GB', 'microSD classe 10', 69.90, 65, 5, 1),
(17, 'Roteador Wi-Fi 6', 'Roteador dual band AX1800', 379.00, 68, 5, 2),
(18, 'Cadeira Gamer', 'Cadeira ergonômica reclinável', 1099.00, 71, 3, 3),
(19, 'Hub USB-C 7 em 1', 'Adaptador multiportas', 159.90, 74, 3, 4),
(20, 'Carregador Turbo 65W', 'Carregador GaN USB-C', 119.90, 77, 3, 5);
 
-- Ordens (30): clientes 1 a 11 e vendedores 1 a 5 em rodízio; valor_total = soma dos itens
INSERT INTO ordem (id_ordem, data_ordem, valor_total, status, id_cliente, id_vendedor) VALUES
(1, '2026-10-28 09:00:00', 7896.00, 'Finalizado', 1, 1),
(2, '2026-10-28 11:07:00', 1128.90, 'Pago', 2, 2),
(3, '2026-10-28 13:14:00', 4296.00, 'Pago', 3, 3),
(4, '2026-10-28 15:21:00', 3228.00, 'Finalizado', 4, 4),
(5, '2026-10-28 17:28:00', 2028.90, 'Pago', 5, 5),
(6, '2026-10-29 09:35:00', 6036.00, 'Pago', 6, 1),
(7, '2026-10-29 11:42:00', 1358.80, 'Finalizado', 7, 2),
(8, '2026-10-29 13:49:00', 249.70, 'Pago', 8, 3),
(9, '2026-10-29 15:56:00', 937.80, 'Pago', 9, 4),
(10, '2026-10-29 17:03:00', 829.70, 'Finalizado', 10, 5),
(11, '2026-10-30 09:10:00', 2388.00, 'Pago', 11, 1),
(12, '2026-10-30 11:17:00', 3836.80, 'Pago', 1, 2),
(13, '2026-10-30 13:24:00', 2933.70, 'Finalizado', 2, 3),
(14, '2026-10-30 15:31:00', 2466.00, 'Pago', 3, 4),
(15, '2026-10-30 17:38:00', 5246.00, 'Pago', 4, 5),
(16, '2026-10-31 09:45:00', 2028.90, 'Finalizado', 5, 1),
(17, '2026-10-31 11:52:00', 1928.90, 'Pago', 6, 2),
(18, '2026-10-31 13:59:00', 2557.80, 'Pago', 7, 3),
(19, '2026-10-31 15:06:00', 2442.90, 'Finalizado', 8, 4),
(20, '2026-10-31 17:13:00', 3856.80, 'Pago', 9, 5),
(21, '2026-11-01 09:20:00', 2018.70, 'Pago', 10, 1),
(22, '2026-11-01 11:27:00', 639.60, 'Finalizado', 11, 2),
(23, '2026-11-01 13:34:00', 4146.00, 'Pago', 1, 3),
(24, '2026-11-01 15:41:00', 2998.90, 'Pago', 2, 4),
(25, '2026-11-01 17:48:00', 3198.80, 'Finalizado', 3, 5),
(26, '2026-11-02 09:55:00', 2748.00, 'Pago', 4, 1),
(27, '2026-11-02 11:02:00', 759.60, 'Pago', 5, 2),
(28, '2026-11-02 13:09:00', 1187.70, 'Finalizado', 6, 3),
(29, '2026-11-02 15:16:00', 1198.90, 'Pago', 7, 4),
(30, '2026-11-02 17:23:00', 2557.70, 'Pago', 8, 5);
 
-- Itens de pedido (60)
INSERT INTO item_pedido (quantidade, valor_unitario, id_ordem, id_produto) VALUES
(3, 999.00, 1, 4),
(1, 4899.00, 1, 1),
(1, 849.00, 2, 9),
(1, 279.90, 2, 8),
(1, 999.00, 3, 4),
(3, 1099.00, 3, 18),
(1, 429.00, 4, 14),
(1, 2799.00, 4, 2),
(1, 1899.00, 5, 3),
(1, 129.90, 5, 7),
(3, 379.00, 6, 17),
(1, 4899.00, 6, 1),
(2, 129.90, 7, 7),
(1, 1099.00, 7, 18),
(2, 44.90, 8, 15),
(1, 159.90, 8, 19),
(2, 39.90, 9, 6),
(2, 429.00, 9, 14),
(2, 349.90, 10, 5),
(1, 129.90, 10, 7),
(1, 1899.00, 11, 3),
(1, 489.00, 11, 13),
(3, 1199.00, 12, 12),
(2, 119.90, 12, 20),
(1, 2799.00, 13, 2),
(3, 44.90, 13, 15),
(1, 999.00, 14, 4),
(3, 489.00, 14, 13),
(1, 1649.00, 15, 10),
(3, 1199.00, 15, 12),
(1, 129.90, 16, 7),
(1, 1899.00, 16, 3),
(1, 279.90, 17, 8),
(1, 1649.00, 17, 10),
(2, 279.90, 18, 8),
(2, 999.00, 18, 4),
(1, 44.90, 19, 15),
(2, 1199.00, 19, 12),
(3, 1199.00, 20, 12),
(2, 129.90, 20, 7),
(1, 1899.00, 21, 3),
(3, 39.90, 21, 6),
(2, 279.90, 22, 8),
(2, 39.90, 22, 6),
(1, 849.00, 23, 9),
(3, 1099.00, 23, 18),
(1, 199.90, 24, 11),
(1, 2799.00, 24, 2),
(1, 2799.00, 25, 2),
(2, 199.90, 25, 11),
(1, 849.00, 26, 9),
(1, 1899.00, 26, 3),
(1, 159.90, 27, 19),
(3, 199.90, 27, 11),
(3, 69.90, 28, 16),
(2, 489.00, 28, 13),
(1, 349.90, 29, 5),
(1, 849.00, 29, 9),
(2, 1099.00, 30, 18),
(3, 119.90, 30, 20);
 
-- Pagamentos (30, um por ordem, valor = soma dos itens)
INSERT INTO pagamento (data_pagamento, valor_pago, forma_pagamento, id_ordem) VALUES
('2026-10-02', 7896.00, 'PIX', 1),
('2026-10-03', 1128.90, 'Cartão', 2),
('2026-10-04', 4296.00, 'Boleto', 3),
('2026-10-05', 3228.00, 'Dinheiro', 4),
('2026-10-06', 2028.90, 'PIX', 5),
('2026-10-07', 6036.00, 'Cartão', 6),
('2026-10-08', 1358.80, 'Boleto', 7),
('2026-10-09', 249.70, 'Dinheiro', 8),
('2026-10-10', 937.80, 'PIX', 9),
('2026-10-11', 829.70, 'Cartão', 10),
('2026-10-12', 2388.00, 'Boleto', 11),
('2026-10-13', 3836.80, 'Dinheiro', 12),
('2026-10-14', 2933.70, 'PIX', 13),
('2026-10-15', 2466.00, 'Cartão', 14),
('2026-10-16', 5246.00, 'Boleto', 15),
('2026-10-17', 2028.90, 'Dinheiro', 16),
('2026-10-18', 1928.90, 'PIX', 17),
('2026-10-19', 2557.80, 'Cartão', 18),
('2026-10-20', 2442.90, 'Boleto', 19),
('2026-10-21', 3856.80, 'Dinheiro', 20),
('2026-10-22', 2018.70, 'PIX', 21),
('2026-10-23', 639.60, 'Cartão', 22),
('2026-10-24', 4146.00, 'Boleto', 23),
('2026-10-25', 2998.90, 'Dinheiro', 24),
('2026-10-26', 3198.80, 'PIX', 25),
('2026-10-27', 2748.00, 'Cartão', 26),
('2026-10-28', 759.60, 'Boleto', 27),
('2026-10-01', 1187.70, 'Dinheiro', 28),
('2026-10-02', 1198.90, 'PIX', 29),
('2026-10-03', 2557.70, 'Cartão', 30);
 

SELECT 'cliente' AS tabela, COUNT(*) AS registros FROM cliente
UNION ALL SELECT 'vendedor', COUNT(*) FROM vendedor
UNION ALL SELECT 'fornecedor', COUNT(*) FROM fornecedor
UNION ALL SELECT 'categoria', COUNT(*) FROM categoria
UNION ALL SELECT 'produto', COUNT(*) FROM produto
UNION ALL SELECT 'ordem', COUNT(*) FROM ordem
UNION ALL SELECT 'item_pedido', COUNT(*) FROM item_pedido
UNION ALL SELECT 'pagamento', COUNT(*) FROM pagamento;
 

select * from vw_cliente;


call BuscarClientePorStatus ('ativo');
call BuscarClientePorStatus ('inativo');



select * from cliente order by  nome ASC;
SELECT id_cliente,nome,email from cliente where email LIKE '%com';

SELECT * FROM vendedor;
SELECT * FROM fornecedor;

SELECT * FROM produto;
SELECT * FROM produto order by preco desc;
SELECT id_produto, nome, preco
FROM produto
WHERE preco > 1000
ORDER BY preco DESC;

SELECT AVG(preco) FROM produto;
SELECT MAX(preco) FROM produto;
SELECT MIN(preco) FROM produto;
SELECT * FROM Produto ORDER BY estoque ASC;
SELECT * FROM Produto ORDER BY estoque DESC;
SELECT * FROM ordem;
select * from ordem where status = 'Finalizado';
select * from ordem where status = 'Pago';
SELECT * FROM item_pedido;


CALL CalcularFaturamentoItem(1);

select * from vw_item_pedido_por_quantidade where quantidade = 1;

SELECT * FROM vw_item_pedido_por_quantidade WHERE quantidade = 2;

select * from vw_item_pedido_por_quantidade where quantidade = 3;

SELECT COUNT(*)from item_pedido; 
SELECT * FROM pagamento;


SELECT MAX(valor_pago) FROM vw_pagamento;
SELECT MIN(valor_pago) FROM vw_pagamento;
SELECT * FROM vw_pagamento where forma_pagamento = 'PIX';
SELECT * FROM vw_pagamento where forma_pagamento = 'Cartão';
SELECT * FROM vw_pagamento where forma_pagamento = 'Boleto';
SELECT * FROM vw_pagamento where forma_pagamento = 'Dinheiro';



CALL AnalisarPagamentos ('PIX');
CALL AnalisarPagamentos ('Cartão');
CALL AnalisarPagamentos ('BOLETO');
CALL AnalisarPagamentos ('DINHEIRO');



SELECT o.id_ordem, o.data_ordem, o.status, o.valor_total,
       c.nome AS cliente, v.nome AS vendedor
  FROM ordem o
  INNER JOIN cliente  c ON c.id_cliente  = o.id_cliente
  INNER JOIN vendedor v ON v.id_vendedor = o.id_vendedor
 ORDER BY o.id_ordem;
 

SELECT i.id_item, i.id_ordem, p.nome AS produto, i.quantidade, i.valor_unitario,
       i.quantidade * i.valor_unitario AS faturamento_item
  FROM item_pedido i
  INNER JOIN produto p ON p.id_produto = i.id_produto
 ORDER BY i.id_item;
 

SELECT o.id_ordem, c.nome AS cliente, pg.forma_pagamento, pg.valor_pago, pg.data_pagamento
  FROM ordem o
  INNER JOIN cliente   c  ON c.id_cliente = o.id_cliente
  INNER JOIN pagamento pg ON pg.id_ordem  = o.id_ordem
 ORDER BY o.id_ordem;
 

SELECT p.id_produto, p.nome AS produto, cat.nome_categoria, f.razao_social AS fornecedor
  FROM produto p
  INNER JOIN categoria  cat ON cat.id_categoria  = p.id_categoria
  INNER JOIN fornecedor f   ON f.id_fornecedor   = p.id_fornecedor
 ORDER BY p.id_produto;
 

SELECT c.id_cliente, c.nome,
       COUNT(o.id_ordem) AS qtd_ordens,
       COALESCE(SUM(o.valor_total), 0) AS total_comprado
  FROM cliente c
  LEFT JOIN ordem o ON o.id_cliente = c.id_cliente
 GROUP BY c.id_cliente, c.nome
 ORDER BY qtd_ordens DESC;
 

SELECT p.id_produto, p.nome,
       COALESCE(SUM(i.quantidade), 0) AS unidades_vendidas
  FROM produto p
  LEFT JOIN item_pedido i ON i.id_produto = p.id_produto
 GROUP BY p.id_produto, p.nome
 ORDER BY unidades_vendidas DESC;
 

SELECT p.id_produto, p.nome,
       p.estoque AS estoque_cadastrado,
       COALESCE(SUM(i.quantidade), 0) AS vendidas,
       p.estoque - COALESCE(SUM(i.quantidade), 0) AS estoque_restante
  FROM produto p
  LEFT JOIN item_pedido i ON i.id_produto = p.id_produto
 GROUP BY p.id_produto, p.nome, p.estoque
 ORDER BY estoque_restante;
 
 SELECT id_produto, nome, descricao, preco
FROM produto
WHERE nome LIKE '%Gamer%'
ORDER BY nome;

SELECT id_produto, nome, estoque
FROM produto
WHERE estoque < 30
ORDER BY estoque;

SELECT id_produto, nome, preco, estoque
FROM produto
WHERE preco <= 200 AND estoque > 50
ORDER BY preco;

SELECT p.id_produto, p.nome AS produto, c.nome_categoria AS categoria, p.preco
FROM produto p
INNER JOIN categoria c ON c.id_categoria = p.id_categoria
ORDER BY c.nome_categoria, p.nome;

SELECT p.id_produto, p.nome AS produto, f.razao_social AS fornecedor
FROM produto p
INNER JOIN fornecedor f ON f.id_fornecedor = p.id_fornecedor
ORDER BY f.razao_social, p.nome;

SELECT o.id_ordem, o.valor_total, p.data_pagamento, p.forma_pagamento, p.valor_pago
FROM ordem o
INNER JOIN pagamento p ON p.id_ordem = o.id_ordem
ORDER BY o.id_ordem;

SELECT o.id_ordem, pr.nome AS produto, i.quantidade, i.valor_unitario,
       i.quantidade * i.valor_unitario AS subtotal
FROM ordem o
INNER JOIN item_pedido i ON i.id_ordem = o.id_ordem
INNER JOIN produto pr ON pr.id_produto = i.id_produto
WHERE o.id_ordem BETWEEN 1 AND 3
ORDER BY o.id_ordem, i.id_item;


SELECT c.id_cliente, c.nome, COUNT(o.id_ordem) AS qtd_pedidos
FROM cliente c
LEFT JOIN ordem o ON o.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY qtd_pedidos DESC, c.nome;

SELECT COUNT(*) AS total_clientes,
       COUNT(CASE WHEN status = 'ativo' THEN 1 END) AS clientes_ativos
FROM cliente;

SELECT COUNT(*) AS total_pedidos,
       SUM(valor_total) AS faturamento_total,
       ROUND(AVG(valor_total), 2) AS ticket_medio,
       MAX(valor_total) AS maior_pedido,
       MIN(valor_total) AS menor_pedido
FROM ordem;

SELECT COUNT(*) AS itens_de_pedido,
       SUM(quantidade) AS unidades_vendidas
FROM item_pedido;

SELECT MAX(preco) AS maior_preco,
       MIN(preco) AS menor_preco,
       ROUND(AVG(preco), 2) AS preco_medio,
       SUM(estoque) AS estoque_total
FROM produto;

SELECT c.nome AS cliente, COUNT(*) AS qtd_pedidos, SUM(o.valor_total) AS total_comprado
FROM ordem o
INNER JOIN cliente c ON c.id_cliente = o.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY total_comprado DESC;


SELECT c.nome_categoria AS categoria, COUNT(*) AS qtd_produtos,
       ROUND(AVG(p.preco), 2) AS preco_medio
FROM produto p
INNER JOIN categoria c ON c.id_categoria = p.id_categoria
GROUP BY c.id_categoria, c.nome_categoria
ORDER BY qtd_produtos DESC;

SELECT forma_pagamento, COUNT(*) AS qtd_pagamentos, SUM(valor_pago) AS total_recebido
FROM pagamento
GROUP BY forma_pagamento
ORDER BY total_recebido DESC;

SELECT SUBSTRING(data_ordem, 1, 7) AS mes, COUNT(*) AS qtd_pedidos,
       SUM(valor_total) AS faturamento
FROM ordem
GROUP BY SUBSTRING(data_ordem, 1, 7)
ORDER BY mes;

SELECT v.nome AS vendedor, COUNT(*) AS qtd_pedidos, SUM(o.valor_total) AS faturamento
FROM ordem o
INNER JOIN vendedor v ON v.id_vendedor = o.id_vendedor
GROUP BY v.id_vendedor, v.nome
HAVING SUM(o.valor_total) > 10000
ORDER BY faturamento DESC;


SELECT p.nome AS produto, SUM(i.quantidade) AS unidades_vendidas,
       SUM(i.quantidade * i.valor_unitario) AS valor_vendido
FROM item_pedido i
INNER JOIN produto p ON p.id_produto = i.id_produto
GROUP BY p.id_produto, p.nome
ORDER BY unidades_vendidas DESC, valor_vendido DESC, p.nome
LIMIT 10;


SELECT id_produto, nome, preco, id_categoria
FROM produto
WHERE id_categoria IN (1, 2)
ORDER BY id_categoria, nome;

SELECT p.id_produto, p.nome AS produto, f.razao_social AS fornecedor
FROM produto p
INNER JOIN fornecedor f ON f.id_fornecedor = p.id_fornecedor
ORDER BY f.razao_social, p.nome;