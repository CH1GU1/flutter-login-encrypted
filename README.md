# Proyecto Login Encriptado con PBKDF2

## Integrantes:
* Kevin Alejandro Mera
* Julian Andres Riascos 
* Alejandro Coronel Sánchez

Este es un proyecto hecho con el framework flutter. El proyecto consiste en una aplicación que permite gestionar los nombres y usuarios de una plataforma.

La aplicación consta de 2 roles: usuario administrador y usuario normal.
El administrador cuenta con las siguientes funcionalidades:
* Consultar los nombres de los usuarios existentes
* Eliminar un usuario
* Establecer en blanco la contraseña de un usuario

Por otra parte, el usuario normal tiene la capacidad de:
* Registrarse en la plataforma
* Realiza el log in en la plataforma
* Cambiar su contraseña
* Consultar su última hora/fecha de Log-in en la plataforma

Con respecto al hashing de las contraseñas, se hace uso del algoritmo PBKDF2


## Desarrollo del Proyecto

Para el desarrollo del proyecto se comenzó por la parte del login y registro, donde lo más dificil que percibimos fue la implementación del hashing de las contraseñas
a la hora de crear los usuarios, y de validar que efectivamente el usuario pudiera ingresar a la plataforma con su contraseña, teniendo en cuenta el hashing de esta última
y su sal. Además, se tenía que comprbrobar que la informacion de la contraseña de los usuarios se guardaba efectivamente en un archivo, donde en nuestro caso es un archivo json.
~~~
  var generator = PBKDF2();
  var salt = generateAsBase64String(10);
  var hash = generator.generateKey(mypass, salt, 1000, 32);
  var encodedHash = base64.encode(hash);
~~~
Como se puede ver, en principio la instancia PBKDF2NS hace uso de un hash SHA-256 por defecto. Así mismo, se generan tanto la sal como el hash, donde ambos se codifican en base 64.

![login](https://i.imgur.com/rM0pqNH.png)

### Pantalla de Usuario normal

Posteriormente, luego de validar que efectivamente el proceso de registro/login se realizaba de manera correcta, procedimos a realizar la pantalla del usuario normal e incluir las
funcionalidades correspondientes a dicho usuario. En este caso, no hubo mayores dificultades a la hora de implementarlas, salvo un ligero inconveniente a la hora de validar que la
última hora de login que se le desplegaba al usuario, correspondía efectivamente a la hora en que este ingresó.

~~~
int intValue = int.parse(thisActiveUser!['ultimoAcceso']);
      Duration offset = const Duration(hours: 5); // Duración de 5 horas
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(intValue);
      DateTime subtractedDateTime = dateTime.subtract(offset);
      String formattedDate =
          DateFormat('dd/MM/yyyy HH:mm:ss').format(subtractedDateTime);
~~~
Esto se resolvió simplemente realizando una conversión a partir de la fecha que se nos arroja originalmente. Asi pues, al sustraer el offset de 5 horas de la fecha original, podemos
obtener la fecha que en efecto corresponde al momento real en el que el usuario ingresó por última vez.

![usernormal](https://i.imgur.com/ohjtZiH.png)

### Pantalla de Usuario Administrador

Finalmente, se realizó la pantalla de administrador junto con sus respectivas funciones. Aqui fue donde tal vez enfrentamos la mayor dificultad, dado que al aún ser novatos trabajando 
en el framework de flutter, tuvimos que resolver varios conflictos a la hora de sincronizar la parte de la vista con el backend, ya que no estamos todavia muy familiarizados con los 
métodos adecuados al momento de realizar dichas tareas en el framework.

![administrator](https://i.imgur.com/uQnpF8D.png)

### Conclusiones

En definitiva, si bien es cierto que el programa cumple con todas las funcionalidades requeridas, tanto de cifrado como la de ambos roles, es cierto que este podría ser mejorado en gran 
medida a través del uso de mejores prácticas en el framework, prácticas de las cuales no estamos muy conscientes aún, pero las que definitivamente dominaremos con el tiempo. Además, al
tener en cuenta el tema de cifrado en los proyectos que realicemos en el futuro, podremos contribuir a la elaboración de programas y/o servicios más seguros y confiables.


