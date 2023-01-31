--Delimiter.

--end

select 
    mm.idMenu as pk,
    mm.idMenu,
    1 as idTipo,
    mm.menu,
    mm.categoria + 1 as idCategoria,
    concat('<select class="select-chosen" style="width:100%" multiple data-placeholder="Grupos asignados" idMenu="',mm.idMenu,'">',(
    	select 
    	    g.idGrupo as '@value',
    	    iif(gm.idMenuM is not null and gm.estado = 1 ,'true','false') as '@selected',
    	    '' + g.grupo
    	from grupos g
    	left join gruposMenuMovil gm on gm.idGrupo = g.idGrupo and gm.idMenu=mm.idMenu
    	where (g.asignable=1 /*or (gm.estado = 1 and g.asignable=0)*/)  for xml path('option')
    ),'</select>')as grupos,
    mm.estado
from menuMovil mm
where mm.categoria = @idCategoria -1

--begin exec actualizarMenu
    update menuMovil set menu = @menu where idMenu=@idMenu
    select 0 as error, 'Actualización correcta' as message
--end

--begin exec actualizarEstado
    update menuMovil set estado = @estado where idMenu=@idMenu
    select 0 as error, 'Actualización correcta' as message
--end

--begin exec actualizarGruposMenu
    declare @idMenuM int = (select idMenuM from gruposMenuMovil where idGrupo=@value and idMenu=@idMenu)
    if(@idMenuM is not null)begin
        update gruposMenuMovil set estado=@selected where idMenuM=@idMenuM
    end  
    else begin
        insert into gruposMenuMovil(idMenu,idGrupo,estado) values(@idMenu,@value,@selected)
    end
    select 0 as error, 'Actualización correcta' as message
--end

--begin categorias
    select *from(
        select 1 as idCategoria,N'Menú Lateral' as categoria 
        union
        select 2 as idCategoria,'Categoría principal' as categoria 
        union
        select 3 as idCategoria,'Menú de grupos' as categoria 
        union
        select 4 as idCategoria,'Menú de organizaciones' as categoria
        union
        select 5 as idCategoria,'Menú de rutas' as categoria
    )as dt
--end