INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_burgershot', 'Burger Shot', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_burgershot', 'Burger Shot', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_burgershot', 'Burger Shot', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('burgershot', 'Burger Shot')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('burgershot',0,'recrue','Recrue',12,'{}','{}'),
	('burgershot',1,'novice','Novice',25,'{}','{}'),
	('burgershot',2,'employed','Employé',36,'{}','{}'),
	('burgershot',3,'viceboss','Co-gérant',48,'{}','{}'),
  	('burgershot',4,'boss','Patron',0,'{}','{}')
;


INSERT INTO `items` (`name`, `label`) VALUES
	('pommedeterre', 'Pomme de terre'),
	('cornichons', 'Cornichons'),
	('cheddar', 'Cheddar'),
	('originalesauce', 'Sauce originale'),
	('bbqsauce', 'Sauce BBQ'),
	('steakboeuf', 'Steak de boeuf'),
	('steakboeufpremium', 'Steak de boeuf Premium'),
	('shotoriginal', 'Shot\'s Original'),
	('doubleshotoriginal', 'Double Shot\'s Original'),
	('bbqshot', 'Shot\'s BBQ'),
	('premiumshot', 'Shot\'s Premium')
;