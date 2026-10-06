import QtQml

QtObject {
    required property var menus

    function open(target) {
        if (!Object.keys(menus).includes(target))
            return false;
        const menu = menus[target];
        const previous = Object.values(menus).find(candidate => candidate.visible);
        for (const candidate of Object.values(menus))
            if (candidate !== menu)
                candidate.close();
        if (menu.open())
            return true;
        if (previous && previous !== menu)
            previous.open();
        return false;
    }
}
