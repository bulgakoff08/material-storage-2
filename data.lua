require("prototypes.items")
require("prototypes.equipment")
require("prototypes.entities")
require("prototypes.recipes")

data:extend({
    {
        type = "item-group",
        name = "ms-material-storage-2",
        icon_size = 128,
        icon = "__material-storage-2__/graphics/material-storage-2.png",
        inventory_order = "m",
        order = "m-a"
    },
    {
        type = "item-subgroup",
        name = "ms-chests",
        group = "ms-material-storage-2",
        order = "a-c"
    },
    {
        type = "item-subgroup",
        name = "ms-details",
        group = "ms-material-storage-2",
        order = "a-de"
    },
    {
        type = "item-subgroup",
        name = "ms-drives",
        group = "ms-material-storage-2",
        order = "a-dr"
    },
    {
        type = "item-subgroup",
        name = "ms-fluids",
        group = "ms-material-storage-2",
        order = "a-f"
    },
    {
        type = "item-subgroup",
        name = "ms-modules",
        group = "ms-material-storage-2",
        order = "a-m"
    }
})