mutable struct NodoA
    vertice::Char
    sig::Union{NodoA, Nothing}
end

mutable struct NodoV
    vertice::Char
    ady::Union{NodoA, Nothing}
    sig::Union{NodoV, Nothing}
end

mutable struct Grafo
    cabeza::Union{NodoV, Nothing}
    cantV::Int
end

function construir(G::Grafo)
    G.cabeza = nothing
    G.cantV = 0
end

function esGrafoVacio(G::Grafo)
    return isnothing(G.cabeza)
end

function crearEstacion(v::Char, s::Union{NodoV, Nothing})
    return NodoV(v, nothing, s)
end

function crearRuta(v::Char, s::Union{NodoA, Nothing})
    return NodoA(v, s)
end

function mostrarMapaDeRutas(G::Grafo)
    p = G.cabeza
    if isnothing(p)
        println("El grafo no tiene estaciones")
    else
        while !isnothing(p)
            print("Estación: ", p.vertice, "  ... Conexiones con otras estaciones: ")
            q = p.ady
            while !isnothing(q)
                print(q.vertice, " ")
                q = q.sig
            end
            println()
            p = p.sig
        end
        println()
    end
end

function ubicarVertice(G::Grafo, v::Char)
    p = G.cabeza
    while !isnothing(p)
        if p.vertice == v
            return p
        end
        p = p.sig
    end
    return nothing
end

function ubicarAnterior(G::Grafo, v::Char)
    p = G.cabeza
    q = nothing
    while !isnothing(p)
        if p.vertice == v
            return q
        end
        q = p
        p = p.sig
    end
    return nothing
end

function ubicarUltimoV(G::Grafo)
    pU = G.cabeza
    for i in 1:G.cantV-1
        pU = pU.sig
    end
    return pU
end

function agregarNuevaEstacion(G::Grafo, v::Char)
    q = ubicarVertice(G, v)
    if isnothing(q)
        p = crearEstacion(v, nothing)
        if isnothing(G.cabeza)
            G.cabeza = p
        else
            pU = ubicarUltimoV(G)
            pU.sig = p
        end
        G.cantV += 1
    else
        println("LA estación ", v, " ya se encuentra en el grafo")
    end
end

function ubicarUltimoA(pLA::Union{NodoA, Nothing})
    pU = pLA
    while !isnothing(pU.sig)
        pU = pU.sig
    end
    return pU
end


function insertarFinalA(pv1::NodoV, v::Char)
    p = crearRuta(v, nothing)
    if isnothing(pv1.ady)
        pv1.ady = p
    else
        pU = ubicarUltimoA(pv1.ady)
        pU.sig = p
    end
end

function agregarNuevaRuta(G::Grafo, v1::Char, v2::Char)
    pv1 = ubicarVertice(G, v1)
    pv2 = ubicarVertice(G, v2)
    if isnothing(pv1) || isnothing(pv2)
        println("Uno o ambas estaciones no existen ", v1)
    else
        insertarFinalA(pv1, v2)
    end
end

function eliminarRutaBus(G::Grafo, v1::Char, v2::Char)
    p1 = ubicarVertice(G, v1)
    p2 = ubicarVertice(G, v2)
    
    if !isnothing(p1) && !isnothing(p2)
        q = p1.ady
        qA = nothing
        
        while !isnothing(q)
            if q.vertice == v2
                break
            end
            
            qA = q
            q = q.sig
        end
        
        if !isnothing(q)
            if !isnothing(qA)
                qA.sig = isnothing(q.sig) ? nothing : q.sig
            else
                p1.ady = isnothing(q.sig) ? nothing : q.sig
            end
        else
            println("No hay relación entre esas dos estaciones")
        end
    else
        println("Una o ambas estaciones no existen")
    end
end

function ubicarElemento(p::NodoV, vertice::Char)
    q = p.ady
    
    while !isnothing(q)
        if q.vertice == vertice
            return q
        end
        q = q.sig
    end
    
    return nothing
end

function ubicarAnterior(p::NodoV, vertice::Char)
    q = p.ady
    r = nothing
    while !isnothing(q)
        if q.vertice == vertice
            return r
        end
        r = q
        q = q.sig
    end
    return nothing
end

function cerrarEstacion(G::Grafo,G2::Grafo, vertice::Char)
    p = ubicarVertice(G, vertice)
    if !isnothing(p)
        q = ubicarAnterior(G, vertice)
        if !isnothing(q)
            q.sig = isnothing(p.sig) ? nothing : p.sig
        else
            G.cabeza = isnothing(p.sig) ? nothing : p.sig
        end
        agregarNuevaEstacion(G2, vertice)
        G.cantV -= 1
        r = G.cabeza
        while !isnothing(r)
            k = ubicarElemento(r, vertice)            
            if !isnothing(k)
                agregarNuevaRutaEspecial(G2, vertice, r.vertice)
                l = ubicarAnterior(r, vertice)
                if isnothing(l)
                    r.ady = isnothing(k.sig) ? nothing : k.sig
                else
                    l.sig = isnothing(k.sig) ? nothing : k.sig
                end
            end
            r = r.sig
        end
    else
        println("No se puede cerrar una estación que no existe")
    end
end

function agregarNuevaRutaEspecial(G::Grafo, v1::Char, v2::Char)
    pv1 = ubicarVertice(G, v1)
    insertarFinalA(pv1, v2)
end

function restaurarEstacion(G::Grafo,G2::Grafo, vertice::Char)
    p = ubicarVertice(G, vertice)
    if !isnothing(p)
        agregarNuevaEstacion(G2, vertice)
        q = p.ady
        while !isnothing(q)            
            agregarNuevaRutaEspecial(G2, vertice, q.vertice)    
            q = q.sig
        end
        q = ubicarAnterior(G, vertice)
        if !isnothing(q)
            q.sig = isnothing(p.sig) ? nothing : p.sig
        else
            G.cabeza = isnothing(p.sig) ? nothing : p.sig
        end
        G.cantV -= 1
    else
        println("No se puede restaurar una estación que no se ha cerrado")
    end
end

function agregarNuevaRutaMutua(G::Grafo, vertice1::Char,vertice2::Char)
    agregarNuevaRuta(G, vertice1, vertice2)
    agregarNuevaRuta(G, vertice2, vertice1)
end

# Ejemplos de uso

#Grafo de estaciones activas
G = Grafo(nothing, 0)
#Grafo de estaciones cerradas
G2 = Grafo(nothing,0)

construir(G)
agregarNuevaEstacion(G, 'A')
agregarNuevaEstacion(G, 'B')
agregarNuevaEstacion(G, 'C')
agregarNuevaEstacion(G, 'D')

agregarNuevaRutaMutua(G, 'A', 'B')
agregarNuevaRutaMutua(G, 'A', 'C')
agregarNuevaRutaMutua(G, 'B', 'D')
agregarNuevaRutaMutua(G, 'C', 'D')

println("Estaciones con sus respectivas conexiones:")
mostrarMapaDeRutas(G)

println("Cierre de la estacion A")
println("")
cerrarEstacion(G,G2,'A')

println("Conexiones sin la estacion A:")
mostrarMapaDeRutas(G) 
println("")

println("Grafo auxiliar para guardar las conexiones de la estacion eliminada:")
mostrarMapaDeRutas(G2)

println("Se restaura la estacion eliminada")
restaurarEstacion(G2,G,'A')
println("")

println("Grafo principal:")
mostrarMapaDeRutas(G)

println("Grafo auxiliar:")
mostrarMapaDeRutas(G2)