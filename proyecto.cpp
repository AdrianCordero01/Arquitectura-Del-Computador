#include <iostream>
#include <vector>
#include <unordered_map>
#include <list>
#include <iomanip>
#include <fstream>
#include <string>
#include <sstream>
#include <algorithm>
#include <cmath>

using namespace std;

/**
 * @struct VertexData
 * @brief Representa la carga de datos de un vértice en el pipeline gráfico.
 * Contiene coordenadas espaciales, vector normal y coordenadas de mapeo UV.
 */
struct VertexData {
    float x, y, z;      /**< Posición en el espacio 3D */
    float nx, ny, nz;   /**< Vector normal para cálculos de iluminación */
    float u, v;         /**< Coordenadas de textura (UV Mapping) */
};

/** @brief Factor de empaquetamiento: Vértices que caben en una línea de 64 bytes. */
const int VTX_POR_LINEA = 2; 
/** @brief Número de conjuntos (Sets) definidos por la arquitectura de la GPU. */
const int NUM_SETS = 64;
/** @brief Grado de asociatividad (Vías) por cada conjunto. */
const int NUM_VIAS = 4;

/**
 * @class Conjunto
 * @brief Entidad que gestiona un Set de la caché utilizando política de reemplazo LRU.
 * Almacena tanto el orden de acceso como los datos del vértice (VertexData).
 */
class Conjunto {
private:
    int viasTotales; /**< Límite de vías del conjunto. */
    /** @brief Diccionario para recuperación inmediata de datos por ID. */
    unordered_map<int, VertexData> almacenamiento; 
    /** @brief Lista de prioridad para determinar qué elemento es el "Menos Recientemente Usado". */
    list<int> lruList; 

public:
    /**
     * @brief Constructor del conjunto.
     * @param nVias Capacidad de almacenamiento del set.
     */
    Conjunto(int nVias) : viasTotales(nVias) {}

    /**
     * @brief Verifica la existencia de un ID y actualiza su prioridad en la lista LRU.
     * @param id Identificador único del vértice.
     * @return true si los datos están en caché (HIT), false en caso contrario (MISS).
     */
    bool consultar(int id) {
        auto it = find(lruList.begin(), lruList.end(), id);
        if (it != lruList.end()) {
            lruList.erase(it);
            lruList.push_front(id);
            return true;
        }
        return false;
    }

    /**
     * @brief Inserta un vértice en el set. Si excede la capacidad, expulsa el elemento LRU.
     * @param id ID del vértice.
     * @param data Estructura con los datos espaciales y de textura.
     */
    void insertar(int id, VertexData data) {
        if (almacenamiento.count(id)) return;

        if (lruList.size() >= (size_t)viasTotales) {
            int expulsado = lruList.back();
            almacenamiento.erase(expulsado);
            lruList.pop_back();
        }
        lruList.push_front(id);
        almacenamiento[id] = data;
    }

    /**
     * @brief Serializa el estado actual del set para el reporte de trazabilidad.
     * @return String con el orden actual de los IDs en el set.
     */
    string obtenerContenido() const {
        string s = "[";
        for (int id : lruList) s += to_string(id) + " ";
        if (!lruList.empty()) s.pop_back();
        s += "]";
        return s;
    }

    /** @brief Limpia el set para iniciar una nueva ejecución. */
    void vaciar() { lruList.clear(); almacenamiento.clear(); }
};

/**
 * @struct Registro
 * @brief Objeto de auditoría para registrar cada acceso a la memoria caché.
 */
struct Registro {
    string sim;      /**< Identificador del caso de prueba. */
    int id;          /**< Vértice solicitado. */
    int bloque;      /**< Bloque de memoria calculado. */
    int set;         /**< Índice del conjunto mapeado. */
    string res;      /**< Resultado del acceso (HIT/MISS). */
    string calculo;  /**< Estado de la unidad de procesamiento (Shader). */
    string estado;   /**< Snapshot del set después del acceso. */
};

/**
 * @class GPUCache
 * @brief Clase maestra que orquestra la simulación completa de la caché y el cómputo.
 */
class GPUCache {
private:
    vector<Conjunto> conjuntos; /**< Banco de conjuntos de la caché. */
    int nSets;                  /**< Configuración de conjuntos. */
    int hits, misses;           /**< Métricas de rendimiento. */
    long long flopsAhorrados;   /**< Estimación de carga de cómputo evitada gracias a los HITs. */
    vector<Registro> historial; /**< Base de datos para la generación del CSV. */

    /**
     * @brief Simula la carga de trabajo de un Vertex Shader.
     * @param id ID del vértice a procesar.
     * @return Confirmación de ejecución del cálculo.
     */
    string ejecutarShader(int id) {
        // Simulación de transformación de matrices (MVP)
        volatile float calc = sin(id) * cos(id);
        return "EJECUTADO";
    }

public:
    /**
     * @brief Crea la estructura de la caché.
     * @param s Número de Sets.
     * @param v Número de Vías.
     */
    GPUCache(int s, int v) : nSets(s), hits(0), misses(0), flopsAhorrados(0) {
        for(int i = 0; i < s; i++) conjuntos.emplace_back(v);
    }

    /**
     * @brief Procesa una petición de vértice aplicando lógica de mapeo y carga de bloques.
     * @param id Referencia del vértice.
     * @param nombreSim Nombre del bloque de datos actual.
     */
    void procesar(int id, string nombreSim) {
        int bloqueID = id / VTX_POR_LINEA;   
        int setIdx = bloqueID % nSets;       
        string resStr, calcStr;

        if (conjuntos[setIdx].consultar(id)) {
            hits++;
            resStr = "HIT";
            calcStr = "SKIP"; 
            flopsAhorrados += 120; // Estimación de operaciones ahorradas
        } else {
            misses++;
            resStr = "MISS";
            calcStr = ejecutarShader(id);
            
            // Carga de ráfaga (Burst): Se trae el bloque completo (2 vértices)
            int inicio = bloqueID * VTX_POR_LINEA;
            for (int i = 0; i < VTX_POR_LINEA; i++) {
                VertexData vtx = {(float)(inicio+i), 0, 0, 0, 0, 0, 0, 0};
                conjuntos[(inicio+i)/VTX_POR_LINEA % nSets].insertar(inicio + i, vtx);
            }
        }
        historial.push_back({nombreSim, id, bloqueID, setIdx, resStr, calcStr, conjuntos[setIdx].obtenerContenido()});
    }

    /** @brief Resetea la caché y contadores para la siguiente simulación. */
    void limpiar() {
        hits = 0; misses = 0; flopsAhorrados = 0;
        for(auto &c : conjuntos) c.vaciar();
    }

    /** @brief Muestra el balance final en consola con formato vistoso. */
    void resumen(string nombre) {
        double total = hits + misses;
        cout << "\n" << string(55, '=') << endl;
        cout << "  REPORTE TECNICO: " << nombre << endl;
        cout << string(55, '-') << endl;
        cout << "  Hit Rate:  " << fixed << setprecision(2) << (hits/total)*100 << "%" << endl;
        cout << "  Ahorro de computo: " << flopsAhorrados << " FLOPs" << endl;
        cout << string(55, '=') << endl;
    }

    /** @brief Genera el reporte CSV con saltos de línea dobles entre experimentos. */
    void exportarCSV(string filename) {
        ofstream file(filename);
        file << "SIMULACION,ID_REF,BLOQUE,CONJUNTO,RESULTADO,ESTADO_GPU,ESTADO_SET_LRU" << endl;
        string ultima = "";
        for (const auto& r : historial) {
            if (!ultima.empty() && ultima != r.sim) file << ",,,,,," << endl << ",,,,,," << endl;
            ultima = r.sim;
            file << r.sim << "," << r.id << "," << r.bloque << "," << r.set << "," 
                 << r.res << "," << r.calculo << ",\"" << r.estado << "\"" << endl;
        }
        file.close();
    }
};

/**
 * @brief Orquestador del sistema. Lee el archivo de entrada y dispara la simulación.
 */
int main() {
    GPUCache miCache(NUM_SETS, NUM_VIAS);
    ifstream entrada("entrada_cache.txt");
    if (!entrada.is_open()) return 1;

    string linea, tag;
    bool activo = false;
    while (getline(entrada, linea)) {
        if (linea.empty()) continue;
        if (linea[0] == '#') {
            if (linea.find("FIN") != string::npos) {
                miCache.resumen(tag);
                miCache.limpiar();
                activo = false;
            } else {
                tag = linea.substr(2);
                activo = true;
            }
            continue;
        }
        if (activo) {
            stringstream ss(linea);
            int val;
            while (ss >> val) miCache.procesar(val, tag);
        }
    }
    entrada.close();
    miCache.exportarCSV("reporte.csv");
    cout << "\n[SISTEMA] 'reporte.csv' generado correctamente." << endl;
    return 0;
}


/*

    #########################################################################################################
    #########################################################################################################

    ######      #######     ######    #######       ######    ######      #######
    ##          ##     #    ##  ##      ##            ##      ##  ##      ##
    ## ###      #### #      ######      ##            ##      ######        #####
    ##   #      ##  ##      ##  ##      ##            ##      ##  ##           ##
    ######      ##  ##      ##  ##      ######      ######    ##  ##       #### 

    #########################################################################################################
    #########################################################################################################

*/