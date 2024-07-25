# TP 1C2024 Key-Value

# Arquitectura de la aplicacion
![Arquitectura](./diagrama%20arquitectura.png)

# Ejecucion de la base de datos
## Iniciar nodos
Levantar los nodos de datos y replicas con los scripts:
```bash
./start_agent1.bash
./start_agent2.bash
./start_replica1.bash
./start_replica2.bash
```

**NOTA**: Si se quieren levantar mas nodos de datos y replicas tiene que seguir la convención:
```elixir
iex --name agent_[numero]@127.0.0.1 -S mix
iex --name replica_[numero]@127.0.0.1 -S mix
```

## Levantar los orquestadores
Dentro de cualquier nodo ejecutar:
```elixir
Init.create_orchestrators() # crea orquestadores master y slave
```

## (Opcional) Cargar datos en los nodos
```elixir
Init.load_data() # carga algunos datos a la base de datos
```

## Hacer peticiones a los servidores
```bash
# Obtener un dato de la clave :key
curl -X GET localhost:<PORT>/datos/:key

# Insertar un dato
curl -X POST localhost:<PORT>/datos --data '{"key":"x","value":"yyy"}'

# Buscar los valores menores a X
curl -X GET localhost:<PORT>/datos/filter/less?filter=X

# Buscar los valores mayores a X
curl -X GET localhost:<PORT>/datos/filter/greather?filter=X

# Eliminar la clave :key
curl -X DELETE localhost:<PORT>/datos/:key
```

## Configuración
En el archivo de [config.exs](config/config.exs) se encuentra la configuracion de la aplicación. Por ejemplo la capacidad máxima por nodo de datos.
