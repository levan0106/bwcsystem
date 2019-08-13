﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BWC.Model;

namespace BWC.Core.Interfaces
{
    public interface IOrderService : IRepository<OrderService>
    {
        IEnumerable<OrderService> GetAll(object orderId);
    }
}
