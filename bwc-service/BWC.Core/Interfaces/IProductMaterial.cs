﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BWC.Model;

namespace BWC.Core.Interfaces
{
    public interface IProductMaterial:IRepository<ProductMaterial>
    {
        IEnumerable<ProductMaterial> GetAll(int productId);
    }
}
