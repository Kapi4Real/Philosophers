/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtins.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ccouton <marvin@42.fr>                     +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/29 00:00:00 by ccouton           #+#    #+#             */
/*   Updated: 2025/06/29 00:00:00 by ccouton          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philosophers.h"

int	main(int argc, char **argv)
{
	t_data	data;
	int		i;

	if (!parse_args(&data, argc, argv))
		return (1);
	if (!init_simulation(&data))
		return (1);
	if (!start_threads(&data))
	{
		write(2, "Error : failed thread\n", 21);
		cleanup(&data);
		return (1);
	}
	i = 0;
	while (i < data.nb_philos)
	{
		pthread_join(data.philos[i].thread, NULL);
		i++;
	}
	pthread_join(data.monitor, NULL);
	cleanup(&data);
	return (0);
}
