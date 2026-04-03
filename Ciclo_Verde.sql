
CREATE DATABASE CICLO_VERDE
USE CICLO_VERDE

CREATE TABLE municipio (
    id_municipio INT AUTO_INCREMENT PRIMARY KEY,
    cnpj BIGINT,
    nome VARCHAR(100)
);

CREATE TABLE endereco (
    id_endereco INT AUTO_INCREMENT PRIMARY KEY,
    logradouro VARCHAR(255),
    bairro VARCHAR(50),
    cidade VARCHAR(45),
    uf VARCHAR(2)
);

CREATE TABLE usuarios (
    id_usuarios INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(45) NOT NULL,
    senha VARCHAR(45) NOT NULL,
    municipio_id INT NOT NULL,
    fk_endereco_id INT NOT NULL,
    FOREIGN KEY (municipio_id) REFERENCES municipio(id_municipio),
    FOREIGN KEY (fk_endereco_id) REFERENCES endereco(id_endereco)
);

CREATE TABLE sementes (
    id_sementes INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(45),
    especie VARCHAR(45),
    descricao TINYTEXT
);

CREATE TABLE fornecedor (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    cnpj BIGINT,
    telefone VARCHAR(45),
    email VARCHAR(100),
    endereco_id INT,
    FOREIGN KEY (endereco_id) REFERENCES endereco(id_endereco)
);

CREATE TABLE armazem (
    id_armazem INT AUTO_INCREMENT PRIMARY KEY,
    lote DOUBLE,
    municipio_id INT,
    endereco_id INT,
    FOREIGN KEY (municipio_id) REFERENCES municipio(id_municipio),
    FOREIGN KEY (endereco_id) REFERENCES endereco(id_endereco)
);

CREATE TABLE lote (
    id_lote INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(45),
    sementes_id INT,
    codigo_lote VARCHAR(45),
    quantidade INT,
    data_entrada DATE,
    data_validade DATE,
    armazem_id INT,
    fornecedor_id INT,
    FOREIGN KEY (sementes_id) REFERENCES sementes(id_sementes),
    FOREIGN KEY (armazem_id) REFERENCES armazem(id_armazem),
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedor(id_fornecedor)
);

CREATE TABLE pedidos (
    id_pedidos INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    data_dePedido DATE,
    status_pedido VARCHAR(45),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuarios)
);

CREATE TABLE item_pedidos (
    id_item_pedidos INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT,
    lote_id INT,
    quantidade INT,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id_pedidos),
    FOREIGN KEY (lote_id) REFERENCES lote(id_lote)
);

CREATE TABLE estoque (
    id_estoque INT AUTO_INCREMENT PRIMARY KEY,
    semente_id INT,
    armazem_id INT,
    quantidade INT,
    FOREIGN KEY (semente_id) REFERENCES sementes(id_sementes),
    FOREIGN KEY (armazem_id) REFERENCES armazem(id_armazem)
);

CREATE TABLE movimento_estoque (
    id_movimento_estoque INT AUTO_INCREMENT PRIMARY KEY,
    semente_id INT,
    armazem_id INT,
    tipo ENUM('entrada','saida'),
    quantidade INT,
    data_movimentacao DATETIME,
    descricao TEXT,
    FOREIGN KEY (semente_id) REFERENCES sementes(id_sementes),
    FOREIGN KEY (armazem_id) REFERENCES armazem(id_armazem)
);

CREATE TABLE entrega (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT,
    data_entrega DATE,
    status_entrega VARCHAR(50),
    transportadora VARCHAR(100),
    responsavel_entrega VARCHAR(100),
    observacoes TEXT,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id_pedidos)
);

DELIMITER $$

CREATE TRIGGER trg_verifica_estoque_negativo
BEFORE UPDATE ON estoque
FOR EACH ROW
BEGIN
    IF NEW.quantidade < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: quantidade em estoque não pode ser negativa.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE registrar_movimentacao(
    IN p_semente_id INT,
    IN p_armazem_id INT,
    IN p_tipo ENUM('entrada','saida'),
    IN p_quantidade INT,
    IN p_descricao TEXT
)
BEGIN
    INSERT INTO movimento_estoque (semente_id, armazem_id, tipo, quantidade, data_movimentacao, descricao)
    VALUES (p_semente_id, p_armazem_id, p_tipo, p_quantidade, NOW(), p_descricao);
END$$

DELIMITER ;



INSERT INTO municipio (cnpj, nome) VALUES
(12345678000101, 'Município A'),
(98765432000199, 'Município B'),
(19283746000155, 'Município C');


INSERT INTO endereco (logradouro, bairro, cidade, uf) VALUES
('Rua das Flores, 100', 'Centro', 'Cidade A', 'SP'),
('Avenida Brasil, 250', 'Jardim América', 'Cidade B', 'RJ'),
('Travessa dos Pássaros, 50', 'Vila Nova', 'Cidade C', 'MG'),
('Rua das Palmeiras, 75', 'Bela Vista', 'Cidade D', 'PR');


INSERT INTO usuarios (nome, senha, municipio_id, fk_endereco_id) VALUES
('João Silva', '123456', 1, 1),
('Carlos Pereira', 'abc123', 1, 2),
('Jones Lira', '1234568', 2, 3),
('Carla Pontes', 'bc123', 3, 4);


INSERT INTO fornecedor (nome, cnpj, telefone, email, endereco_id) VALUES
('Agro Fornecedor Ltda', 11122233000144, '11987654321', 'contato@agrofornecedor.com', 1),
('Sementes Brasil', 22233344000155, '21987654321', 'vendas@sementesbrasil.com', 2);


INSERT INTO sementes (nome, especie, descricao) VALUES
('Semente de Milho', 'Milho', 'Semente de alta produtividade para plantio'),
('Semente de Feijão', 'Feijão', 'Semente resistente a pragas'),
('Semente de Soja', 'Soja', 'Semente de soja orgânica');

INSERT INTO armazem (lote, municipio_id, endereco_id) VALUES
(101.0, 1, 1),
(102.0, 2, 2);

INSERT INTO lote (nome, sementes_id, codigo_lote, quantidade, data_entrada, data_validade, armazem_id, fornecedor_id) VALUES
('Lote Milho 2025', 1, 'MIL2025001', 500, '2025-10-01', '2026-10-01', 1, 1),
('Lote Feijão 2025', 2, 'FEI2025002', 300, '2025-09-15', '2026-09-15', 2, 2);


INSERT INTO pedidos (usuario_id, data_dePedido, status_pedido) VALUES
(1, '2025-10-10', 'Em processamento'),
(2, '2025-10-12', 'Concluído'),
(1, '2025-10-13', 'Em processamento'),
(2, '2025-10-14', 'Concluído'),
(1, '2025-10-15', 'Em processamento'),
(2, '2025-10-15', 'Concluído'),
(1, '2025-10-16', 'Em processamento'),
(2, '2025-10-16', 'Concluído'),
(1, '2025-10-17', 'Em processamento'),
(2, '2025-10-17', 'Concluído');


INSERT INTO item_pedidos (pedido_id, lote_id, quantidade) VALUES
(1, 1, 50),
(1, 2, 20),
(2, 1, 30);

INSERT INTO estoque (semente_id, armazem_id, quantidade) VALUES
(1, 1, 500),
(2, 2, 300);


INSERT INTO movimento_estoque (semente_id, armazem_id, tipo, quantidade, data_movimentacao, descricao) VALUES
(1, 1, 'entrada', 500, NOW(), 'Entrada inicial de milho'),
(2, 2, 'entrada', 300, NOW(), 'Entrada inicial de feijão');


INSERT INTO entrega (pedido_id, data_entrega, status_entrega, transportadora, responsavel_entrega, observacoes) VALUES
(1, '2025-10-15', 'Em transporte', 'Transportadora XYZ', 'José da Silva', 'Entrega prevista para manhã'),
(2, '2025-10-14', 'Entregue', 'Transportadora ABC', 'Maria Oliveira', 'Entrega realizada com sucesso'),
(3, '2025-10-16', 'Em transporte', 'Transportadora XYZ', 'Pedro Santos', 'Entrega prevista à tarde'),
(4, '2025-10-15', 'Entregue', 'Transportadora ABC', 'Ana Lima', 'Entrega realizada'),
(5, '2025-10-17', 'Em transporte', 'Transportadora XYZ', 'Lucas Silva', 'Entrega prevista'),
(6, '2025-10-16', 'Entregue', 'Transportadora ABC', 'Carla Souza', 'Entrega realizada'),
(7, '2025-10-18', 'Em transporte', 'Transportadora XYZ', 'Paulo Costa', 'Entrega prevista'),
(8, '2025-10-19', 'Em transporte', 'Transportadora ABC', 'Fernanda Lima', 'Entrega prevista'),
(9, '2025-10-20', 'Entregue', 'Transportadora XYZ', 'Rafael Rocha', 'Entrega realizada'),
(10, '2025-10-21', 'Em transporte', 'Transportadora ABC', 'Mariana Alves', 'Entrega prevista');

select*from entrega;

select*from municipio;

select*from usuarios;